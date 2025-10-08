# Testing with HURL

Website: https://hurl.dev

**Important note:** Specific tests of the frontend depend on the theme used and may need to be adapted. The tests provided here have been developed for the **default** and **manuscript** themes of OJS 3.3.

## Install HURL

Install via your system package manager. See [HURL website](https://hurl.dev/docs/installation.html).

## Setting default variables

Edit or create a file `vars.env` with the following content:

```bash
BASE_URL=<your default OJS URL>
TEST_USERNAME=<your OJS username to run authenticated tests>
```

## General Usage

Run a specific set of tests for a specified URL:

```bash
hurl --variable BASE_URL=https://opengenderjournal.de --test prio1.hurl
```

Note: In case of issues with expired SSL certificates you can add the options `--insecure` or `--ssl-no-revoke` to the command line.

Run a specific test file with default variables:

```bash
hurl --variables-file vars.env --test prio1.hurl
```

Run all Hurl tests in the current directory (depending on the tests this may require authentication, see below):

```bash
hurl --variables-file vars.env --test .
```

Run a test file and create a report in HTML format:

```bash
hurl --variables-file vars.env --report-html results --test prio1.hurl
```

## Usage with authentication

Set password via environment variable.

### On Linux or MacOS (Bash)

```bash
export HURL_TEST_PASSWORD="my_value"
```

### On Windows (Powershell)

```ps1
$HURL_TEST_PASSWORD = "my_value"
```

Run a specific test file with authentication:

```bash
hurl --variables-file vars.env --secret TEST_PASSWORD=$HURL_TEST_PASSWORD --test prio1-auth.hurl
```

## Available test files

- `prio1.hurl`: Priority 1 tests as listed in the [test cases overview csv file](https://github.com/mpbraendle/OJS-Tests/blob/main/Test_Cases-EN.csv) (no authentication required)
- `prio1-auth.hurl`: Priority 1 tests as listed in the [test cases overview csv file](https://github.com/mpbraendle/OJS-Tests/blob/main/Test_Cases-EN.csv) (authentication required)

## Advanced examples

This currently doesn't work with authentication if the password is different for different URLs.

### Run tests from a Windows (Powershell) system for multiple URLs

Create a file `urls.txt` with the URLs you want to test, one per line and run the following script:

```Powershell
Get-Content urls.txt | ForEach-Object { Write-Host $_; hurl --variable BASE_URL=$_ --report-html results --test prio1.hurl }
```

This will create a subdirectory `results` with an index.html file that summarizes the results for all URLs.

### Run tests from a Windows (Powershell) system for multiple URLs and extract data from a JSON report

Create a file `urls.txt` with the URLs you want to test, one per line and run the following script:

```Powershell
# Run the HURL test for each URL and generate a JSON report
Get-Content urls.txt | ForEach-Object { Write-Host $_; hurl --variable BASE_URL=$_ --report-json results-json --test prio1.hurl }

# Extract information from the JSON report
(Get-Content results-json\report.json -Raw | ConvertFrom-Json) | Select-Object -ExpandProperty entries | Where-Object { $_.index -eq '1' } | ForEach-Object {
    $_ | Select-Object -ExpandProperty calls | Select-Object -First 1 @{N='url';E={$_.request.url}},@{N='issuer';E={$_.response.certificate.issuer}},@{N='expiry';E={$_.response.certificate.expire_date}}
} | Export-Csv certificates.csv -NoTypeInformation
```

This will create a subdirectory `results-json` with a `report.json` file that contains the full test results in JSON format. The second part of the script extracts the URL, issuer, and expiry date of the SSL certificate from the first request of each entry and saves it to a CSV file named `certificates.csv`.
