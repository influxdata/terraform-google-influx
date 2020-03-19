package test

import (
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/packer"
	"github.com/influxdata/influxdb/client/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const KEY_REGION = "region"
const KEY_ZONE = "zone"
const KEY_PROJECT = "project"
const KEY_RANDOM_ID = "random-id"

type PackerInfo struct {
	templatePath string
	builderName  string
}

func getRandomRegion(t *testing.T, projectID string) string {
	approvedRegions := []string{"europe-north1", "europe-west1", "europe-west2", "europe-west3", "us-central1", "us-east1", "us-west1"}
	return gcp.GetRandomRegion(t, projectID, approvedRegions, []string{})
}

func createPackerOptions(templatePath string, builderName string, project string, region string, zone string) *packer.Options {
	return &packer.Options{
		Template: templatePath,
		Only:     builderName,
		Vars: map[string]string{
			"project_id": project,
			"region":     region,
			"zone":       zone,
		},
	}
}

func buildImage(t *testing.T, templatePath string, builderName string, project string, region string, zone string) string {
	options := &packer.Options{
		Template: templatePath,
		Only:     builderName,
		Vars: map[string]string{
			"project_id": project,
			"region":     region,
			"zone":       zone,
		},
	}

	return packer.BuildArtifact(t, options)
}

func deleteImage(t *testing.T, project string, imageName string) {
	image := gcp.FetchImage(t, project, imageName)
	image.DeleteImage(t)
}

func getNodePublicIP(t *testing.T, exampleDir string, outputName string) string {
	maxRetries := 15
	sleepBetweenRetries := 5 * time.Second

	publicIp, err := retry.DoWithRetryE(t, "Get public IP for a Data instance", maxRetries, sleepBetweenRetries, func() (string, error) {
		projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
		instanceGroup := getInstanceGroup(t, exampleDir, outputName)

		instances := instanceGroup.GetInstances(t, projectId)

		if instances == nil || len(instances) == 0 {
			return "", errors.New("Could not find instances")
		}

		instance := instances[0]
		publicIP := instance.GetPublicIp(t)
		logger.Logf(t, "Public IP found: %v", publicIP)

		return publicIP, nil
	})

	require.NoError(t, err, "Could not find public IP")
	return publicIp
}

func getInstanceGroup(t *testing.T, exampleDir string, outputName string) *gcp.RegionalInstanceGroup {
	region := test_structure.LoadString(t, exampleDir, KEY_REGION)
	projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
	terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
	igSelfLink := terraform.Output(t, terraformOptions, outputName)
	nameArr := strings.Split(igSelfLink, "/")
	name := nameArr[len(nameArr)-1]
	return gcp.FetchRegionalInstanceGroup(t, projectId, region, name)
}

func validateInfluxdb(t *testing.T, endpoint string, port string) {
	databaseName := "automatedtest"
	metric := "temperature"
	city := "Aurora"
	value := int64(50)
	timestamp := time.Now()

	c, err := client.NewHTTPClient(client.HTTPConfig{
		Addr:    fmt.Sprintf("http://%s:%s", endpoint, port),
		Timeout: time.Second * 60,
	})

	require.NoError(t, err, "Unable to connect to InfluxDB endpoint")

	defer c.Close()

	maxRetries := 15
	sleepBetweenRetries := 5 * time.Second

	// Create database
	retry.DoWithRetry(t, "Querying database", maxRetries, sleepBetweenRetries, func() (string, error) {
		response, err := c.Query(client.Query{
			Command: fmt.Sprintf("CREATE DATABASE %s", databaseName),
		})

		if err != nil {
			logger.Logf(t, "Query failed: %s", err.Error())
			return "", err
		}

		if response.Error() != nil {
			logger.Logf(t, "Query failed: %s", response.Error().Error())
			return "", response.Error()
		}

		return "", nil
	})

	// Write to database
	branchPoints, err := client.NewBatchPoints(client.BatchPointsConfig{
		Database:  databaseName,
		Precision: "s",
	})

	require.NoError(t, err, "Unable to create branch points")

	point, err := client.NewPoint(
		metric,
		map[string]string{"city": city},
		map[string]interface{}{"value": value},
		timestamp,
	)

	require.NoError(t, err, "Unable to create a point")

	branchPoints.AddPoint(point)
	err = c.Write(branchPoints)
	require.NoError(t, err, "Unable to write to database")

	// Read from database
	response, err := c.Query(client.Query{
		Command:  fmt.Sprintf("SELECT * FROM %s", metric),
		Database: databaseName,
	})

	require.NoError(t, err, "Unable to read from database")
	require.NoError(t, response.Error(), "Query failed")

	assert.Len(t, response.Results, 1)

	// Verify returned result
	series := response.Results[0].Series[0]

	assert.Equal(t, metric, series.Name)
	assert.Equal(t, city, series.Values[0][1])

	returnedValue, _ := series.Values[0][2].(json.Number).Int64()
	assert.Equal(t, value, returnedValue)
}

func validateTelegraf(t *testing.T, endpoint string, port string, databaseName string) {
	c, err := client.NewHTTPClient(client.HTTPConfig{
		Addr:    fmt.Sprintf("http://%s:%s", endpoint, port),
		Timeout: time.Second * 60,
	})

	require.NoError(t, err, "Unable to connect to InfluxDB endpoint")

	defer c.Close()

	maxRetries := 15
	sleepBetweenRetries := 5 * time.Second

	// Create database
	retry.DoWithRetry(t, "Querying telegraf database", maxRetries, sleepBetweenRetries, func() (string, error) {

		// Read from database
		response, err := c.Query(client.Query{
			Command:  "SELECT * FROM cpu",
			Database: databaseName,
		})

		if err != nil {
			logger.Logf(t, "Telegraf query failed: %s", err.Error())
			return "", err
		}

		if response.Error() != nil {
			logger.Logf(t, "Telegraf query error: %s", response.Error().Error())
			return "", response.Error()
		}

		assert.NotEmpty(t, response.Results)

		return "", nil
	})
}

func validateChronograf(t *testing.T, endpoint string, port string) {
	maxRetries := 30
	sleepBetweenRetries := 4 * time.Second
	url := fmt.Sprintf("http://%s:%s", endpoint, port)

	logger.Log(t, "Checking URL: %s", url)

	http_helper.HttpGetWithRetryWithCustomValidation(t, url, maxRetries, sleepBetweenRetries, func(status int, body string) bool {
		return status == 200
	})
}

func validateKapacitor(t *testing.T, endpoint string, port string) {
	maxRetries := 30
	sleepBetweenRetries := 4 * time.Second
	url := fmt.Sprintf("http://%s:%s/kapacitor/v1/ping", endpoint, port)

	logger.Log(t, "Checking URL: %s", url)

	http_helper.HttpGetWithRetryWithCustomValidation(t, url, maxRetries, sleepBetweenRetries, func(status int, body string) bool {
		return status == 204
	})
}
