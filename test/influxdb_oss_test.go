package test

import (
	"fmt"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

const EXAMPLE_DIR_INFLUXDB_OSS = "influxdb-oss"

func TestInfluxDBOSS(t *testing.T) {
	t.Parallel()

	// For convenience - uncomment these as well as the "os" import
	// when doing local testing if you need to skip any sections.
	// os.Setenv("SKIP_", "true")
	//os.Setenv("SKIP_bootstrap", "true")
	//os.Setenv("SKIP_build_image", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_validate", "true")
	//os.Setenv("SKIP_teardown", "true")

	// Keeping the testcases struct, even though we're only running a single test

	var testcases = []struct {
		testName      string
		testDir       string
		igOutput      string
		packerInfo    PackerInfo
		sleepDuration int
	}{
		{
			"TestInfluxDBOSS",
			EXAMPLE_DIR_INFLUXDB_OSS,
			"influxdb_instance_group",
			PackerInfo{
				builderName:  "gcp",
				templatePath: "influxdb-oss/influxdb-oss.json"},
			0,
		},
	}

	for _, testCase := range testcases {
		// The following is necessary to make sure testCase's values don't
		// get updated due to concurrency within the scope of t.Run(..) below
		testCase := testCase

		t.Run(testCase.testName, func(t *testing.T) {
			t.Parallel()

			// This is terrible - but attempt to stagger the test cases to
			// avoid a concurrency issue
			time.Sleep(time.Duration(testCase.sleepDuration) * time.Second)

			_examplesDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
			exampleDir := filepath.Join(_examplesDir, testCase.testDir)

			test_structure.RunTestStage(t, "bootstrap", func() {
				projectId := gcp.GetGoogleProjectIDFromEnvVar(t)
				region := getRandomRegion(t, projectId)
				zone := gcp.GetRandomZoneForRegion(t, projectId, region)
				randomId := strings.ToLower(random.UniqueId())

				test_structure.SaveString(t, exampleDir, KEY_REGION, region)
				test_structure.SaveString(t, exampleDir, KEY_ZONE, zone)
				test_structure.SaveString(t, exampleDir, KEY_PROJECT, projectId)
				test_structure.SaveString(t, exampleDir, KEY_RANDOM_ID, randomId)
			})

			defer test_structure.RunTestStage(t, "teardown", func() {
				terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
				projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
				terraform.Destroy(t, terraformOptions)

				imageName := test_structure.LoadArtifactID(t, exampleDir)
				deleteImage(t, projectId, imageName)
			})

			test_structure.RunTestStage(t, "build_image", func() {
				region := test_structure.LoadString(t, exampleDir, KEY_REGION)
				projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
				zone := test_structure.LoadString(t, exampleDir, KEY_ZONE)
				randomId := test_structure.LoadString(t, exampleDir, KEY_RANDOM_ID)

				imagesDir := fmt.Sprintf("%s/machine-images", _examplesDir)
				templatePath := fmt.Sprintf("%s/%s", imagesDir, testCase.packerInfo.templatePath)

				imageID := buildImage(t, templatePath, testCase.packerInfo.builderName, projectId, region, zone)
				test_structure.SaveArtifactID(t, exampleDir, imageID)

				baseName := "influxdb-oss"

				clusterName := fmt.Sprintf("%s-%s", baseName, randomId)

				// The vars here cover both OSS and Enterprise distributions
				terraformOptions := &terraform.Options{
					// The path to where your Terraform code is located
					TerraformDir: exampleDir,
					Vars: map[string]interface{}{
						"region":  region,
						"project": projectId,
						"image":   imageID,
						"name":    clusterName,
					},
				}

				test_structure.SaveTerraformOptions(t, exampleDir, terraformOptions)
			})

			test_structure.RunTestStage(t, "deploy", func() {
				terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
				terraform.InitAndApply(t, terraformOptions)
			})

			test_structure.RunTestStage(t, "validate", func() {
				publicIP := getNodePublicIP(t, exampleDir, testCase.igOutput)
				port := "8086"
				validateInfluxdb(t, publicIP, port)
			})
		})
	}
}
