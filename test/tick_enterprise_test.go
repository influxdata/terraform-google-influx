package test

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/packer"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

const EXAMPLE_DIR_TICK_ENTERPRISE = "tick-enterprise-standalone"
const TELEGRAF_ARTIFACT_ID = "tArtifact"
const INFLUXDB_ARTIFACT_ID = "iArtifact"
const CHRONOGRAF_ARTIFACT_ID = "cArtifact"
const KAPACITOR_ARTIFACT_ID = "kArtifact"

func TestTICKEnterprise(t *testing.T) {
	t.Parallel()

	// For convenience - uncomment these as well as the "os" import
	// when doing local testing if you need to skip any sections.
	// os.Setenv("SKIP_", "true")
	//os.Setenv("SKIP_bootstrap", "true")
	//os.Setenv("SKIP_build_images", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_validate", "true")
	//os.Setenv("SKIP_teardown", "true")

	// Keeping the testcases struct, even though we're only running a single test

	var testcases = []struct {
		testName             string
		testDir              string
		telegrafPackerInfo   PackerInfo
		influxdbPackerInfo   PackerInfo
		chronografPackerInfo PackerInfo
		kapacitorPackerInfo  PackerInfo
		influxdbMIGOutput    string
		chronografMIGOutput  string
		kapacitorMIGOutput   string
		sleepDuration        int
	}{
		{
			"Standalone",
			EXAMPLE_DIR_TICK_ENTERPRISE,
			PackerInfo{
				builderName:  "gcp",
				templatePath: "telegraf/telegraf.json"},
			PackerInfo{
				builderName:  "gcp",
				templatePath: "influxdb-enterprise/influxdb-enterprise.json"},
			PackerInfo{
				builderName:  "gcp",
				templatePath: "chronograf/chronograf.json"},
			PackerInfo{
				builderName:  "gcp",
				templatePath: "kapacitor/kapacitor.json"},
			"influxdb_data_instance_group",
			"chronograf_instance_group",
			"kapacitor_instance_group",
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

				tArtifactID := test_structure.LoadString(t, exampleDir, TELEGRAF_ARTIFACT_ID)
				iArtifactID := test_structure.LoadString(t, exampleDir, INFLUXDB_ARTIFACT_ID)
				cArtifactID := test_structure.LoadString(t, exampleDir, CHRONOGRAF_ARTIFACT_ID)
				kArtifactID := test_structure.LoadString(t, exampleDir, KAPACITOR_ARTIFACT_ID)

				deleteImage(t, projectId, tArtifactID)
				deleteImage(t, projectId, iArtifactID)
				deleteImage(t, projectId, cArtifactID)
				deleteImage(t, projectId, kArtifactID)
			})

			test_structure.RunTestStage(t, "build_images", func() {
				licenseKey := os.Getenv("LICENSE_KEY")
				sharedSecret := os.Getenv("SHARED_SECRET")

				require.NotEmpty(t, licenseKey, "License key must be set as an env var and not included as plain-text")
				require.NotEmpty(t, sharedSecret, "Shared secret must be set as an env var and not included as plain-text")

				region := test_structure.LoadString(t, exampleDir, KEY_REGION)
				projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
				zone := test_structure.LoadString(t, exampleDir, KEY_ZONE)
				randomId := test_structure.LoadString(t, exampleDir, KEY_RANDOM_ID)

				imagesDir := fmt.Sprintf("%s/machine-images", _examplesDir)

				telegrafTemplatePath := fmt.Sprintf("%s/%s", imagesDir, testCase.telegrafPackerInfo.templatePath)
				influxTemplatePath := fmt.Sprintf("%s/%s", imagesDir, testCase.influxdbPackerInfo.templatePath)
				chronografTemplatePath := fmt.Sprintf("%s/%s", imagesDir, testCase.chronografPackerInfo.templatePath)
				kapacitorTemplatePath := fmt.Sprintf("%s/%s", imagesDir, testCase.kapacitorPackerInfo.templatePath)

				packerMap := make(map[string]*packer.Options)

				packerMap["t"] = createPackerOptions(telegrafTemplatePath, testCase.telegrafPackerInfo.builderName, projectId, region, zone)
				packerMap["i"] = createPackerOptions(influxTemplatePath, testCase.influxdbPackerInfo.builderName, projectId, region, zone)
				packerMap["c"] = createPackerOptions(chronografTemplatePath, testCase.chronografPackerInfo.builderName, projectId, region, zone)
				packerMap["k"] = createPackerOptions(kapacitorTemplatePath, testCase.kapacitorPackerInfo.builderName, projectId, region, zone)

				imageIds, err := packer.BuildArtifactsE(t, packerMap)
				test_structure.SaveString(t, exampleDir, TELEGRAF_ARTIFACT_ID, imageIds["t"])
				test_structure.SaveString(t, exampleDir, INFLUXDB_ARTIFACT_ID, imageIds["i"])
				test_structure.SaveString(t, exampleDir, CHRONOGRAF_ARTIFACT_ID, imageIds["c"])
				test_structure.SaveString(t, exampleDir, KAPACITOR_ARTIFACT_ID, imageIds["k"])

				require.NoError(t, err, "Some of Packer builds failed")

				clusterName := fmt.Sprintf("%s-%s", "tick-ent", randomId)

				terraformOptions := &terraform.Options{
					// The path to where your Terraform code is located
					TerraformDir: exampleDir,
					Vars: map[string]interface{}{
						"region":           region,
						"project":          projectId,
						"name_prefix":      clusterName,
						"telegraf_image":   imageIds["t"],
						"influxdb_image":   imageIds["i"],
						"chronograf_image": imageIds["c"],
						"kapacitor_image":  imageIds["k"],
						"license_key":      licenseKey,
						"shared_secret":    sharedSecret,
					},
				}

				test_structure.SaveTerraformOptions(t, exampleDir, terraformOptions)
			})

			test_structure.RunTestStage(t, "deploy", func() {
				terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
				terraform.InitAndApply(t, terraformOptions)
			})

			test_structure.RunTestStage(t, "validate", func() {
				influxIP := getNodePublicIP(t, exampleDir, testCase.influxdbMIGOutput)
				kapacitorIP := getNodePublicIP(t, exampleDir, testCase.kapacitorMIGOutput)
				chronografIP := getNodePublicIP(t, exampleDir, testCase.chronografMIGOutput)

				validateInfluxdb(t, influxIP, "8086")
				validateChronograf(t, chronografIP, "8888")
				validateKapacitor(t, kapacitorIP, "9092")
				validateTelegraf(t, influxIP, "8086", "telegraf")
			})
		})
	}
}
