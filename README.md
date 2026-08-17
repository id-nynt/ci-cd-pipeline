# Simple CI/CD Demo

This repository demonstrates a simple CI/CD pipeline for an online payment service. It uses modular Bash scripts and a GitHub Actions workflow to show how a new release can be validated, deployed, fail a production health check, and automatically roll back to the previous version.

The project is intentionally lightweight. There is no real payment API yet. The goal is to clearly demonstrate the CI/CD recovery flow.

## Quick Start

Run the full local demo from the repository root:

```sh
./scripts/pipeline.sh
```

On Windows PowerShell, use Git Bash directly if normal `bash` points to WSL:

```powershell
& 'C:\Program Files\Git\bin\bash.exe' scripts/pipeline.sh
```

To inspect the final state:

```sh
./scripts/show-state.sh
```

The same pipeline is also available in GitHub Actions:

```text
.github/workflows/ci-cd-pipeline.yml
```

It runs on pushes to `main` and pull requests targeting `main`.

## Service Explanation

The repository simulates an online payment service with two versions:

| Version | Purpose                     | Location  |
| ------- | --------------------------- | --------- |
| `v1`    | Stable production version   | `app/v1/` |
| `v2`    | New version being delivered | `app/v2/` |

Each version contains:

- `config.json`: service metadata, including version and service name.
- `health.txt`: simple health status. The expected healthy value is `OK`.
- `index.html`: placeholder application page.

Deployments are simulated by copying files into:

- `deployments/staging/`
- `deployments/production/`

Runtime state is tracked in:

- `state/production_version.txt`
- `state/previous_production_version.txt`
- `state/staging_version.txt`
- `state/force_production_health_failure`

The `state/force_production_health_failure` file is the deliberate failure marker. When it exists, the production health check fails.

## Pipeline Flow

The full local pipeline is orchestrated by:

```sh
./scripts/pipeline.sh
```

Flow:

```text
reset local state
build v2
test v2
security scan v2
deploy v2 to staging
health-check staging
inject production failure
deploy v2 to production
health-check production
rollback production to v1
show final state
```

Scenario:

1. Production starts on `v1`.
2. `v2` passes build, test, security, staging deployment, and staging health.
3. A failure marker is created before production health check.
4. `v2` is deployed to production.
5. Production health check fails because the marker exists.
6. `rollback.sh production` restores production to `v1`.
7. The failure marker is removed during rollback.

## Expected Output

The exact log formatting may vary slightly, but a successful run should show this sequence:

```text
[reset] PASS: production reset to v1
[build] PASS
[tests] PASS
[security] PASS
[deploy] PASS: deployed v2 to staging
[health-check] PASS: staging health
[inject-failure] PASS: production health check will fail
[deploy] PASS: deployed v2 to production
[health-check] FAIL: forced failure for production
PRODUCTION HEALTH FAILED
TRIGGERING HARDCODED RECOVERY: Rolling back...
[rollback] PASS: restored production to v1
PIPELINE COMPLETED SUCCESSFULLY
```

Final state should be:

```text
Production version: v1
Previous production version: v1
Staging version: v2
Production deployed config version: "version": "1.0"
Staging deployed config version: "version": "2.0"
Forced production health failure: disabled
```

In GitHub Actions, the `Check production health` step is expected to fail internally. The workflow continues, confirms that the failure happened, rolls back production, and verifies recovery.

## Scripts Explanation

| Script                                 | What it does                                                                                                |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `scripts/pipeline.sh`                  | Runs the full demo from reset through rollback and final state display                                      |
| `scripts/reset.sh`                     | Creates required runtime folders, clears old state, and restores production to `v1`                         |
| `scripts/build.sh v2`                  | Checks that the selected app version exists and has a `config.json` with a version field                    |
| `scripts/run-tests.sh v2`              | Checks that the selected version is the `payment-service` and has `health.txt` containing `OK`              |
| `scripts/security-scan.sh v2`          | Searches the selected version for simple hardcoded password, API key, and AWS key patterns                  |
| `scripts/deploy.sh staging v2`         | Copies the selected version into the staging deployment folder and records staging version                  |
| `scripts/deploy.sh production v2`      | Copies the selected version into production and records the previous production version for rollback        |
| `scripts/health-check.sh staging`      | Verifies that deployed staging health exists and contains `OK`                                              |
| `scripts/health-check.sh production`   | Fails if the forced failure marker exists; otherwise verifies deployed production health                    |
| `scripts/inject-failure.sh production` | Creates `state/force_production_health_failure` to simulate production health failure                       |
| `scripts/rollback.sh production`       | Restores production to the previous recorded version and removes the failure marker                         |
| `scripts/show-state.sh`                | Prints current production, previous production, staging, deployed config versions, and failure marker state |

Manual stage-by-stage run:

```sh
./scripts/reset.sh
./scripts/build.sh v2
./scripts/run-tests.sh v2
./scripts/security-scan.sh v2
./scripts/deploy.sh staging v2
./scripts/health-check.sh staging
./scripts/inject-failure.sh production
./scripts/deploy.sh production v2
./scripts/health-check.sh production
./scripts/rollback.sh production
./scripts/show-state.sh
```

`./scripts/health-check.sh production` should fail after failure injection. That failure is expected and is what triggers rollback.

## Repository Structure

```text
.
|-- .github/workflows/ci-cd-pipeline.yml
|-- app/
|   |-- v1/
|   `-- v2/
|-- deployments/
|   |-- production/
|   `-- staging/
|-- scripts/
|-- state/
|-- .gitignore
`-- README
```

`deployments/` and `state/` are runtime simulation folders. Their generated contents are ignored by Git.

## Troubleshooting

If scripts are not executable on Linux or GitHub Actions:

```sh
chmod +x scripts/*.sh
```

If local state looks wrong:

```sh
./scripts/reset.sh
```

If production health does not fail during the scenario, check that this file exists before the production health check:

```text
state/force_production_health_failure
```

## Limitations

The recovery behaviour is predefined.

The pipeline does not reason about:

- why the deployment failed
- whether retrying would help
- whether rollback is appropriate
- whether another recovery action exists
