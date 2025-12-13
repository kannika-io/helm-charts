{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kannika-operator.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kannika-operator.chart" -}}
{{- $name := required "appName is required" .Chart.Name -}}
{{- $version := required "appVersion is required" .Chart.AppVersion -}}
{{- printf "%s-%s" $name $version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Base labels
*/}}
{{- define "kannika-operator.baseLabels" -}}
app.kubernetes.io/name: {{ include "kannika-operator.name" . }}
helm.sh/chart: {{ include "kannika-operator.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: operator
app.kubernetes.io/part-of: "kannika"
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Base labels plus version label
*/}}
{{- define "kannika-operator.labels" -}}
{{- include "kannika-operator.baseLabels" . }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
{{- end -}}

{{/*
{{- end -}}

{{/*
Base labels plus version label
*/}}
{{- define "kannika-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kannika-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use for the main application
*/}}
{{- define "kannika-operator.serviceAccount" -}}
{{- $serviceAccountName :=  default (printf "%s-%s" (include "kannika-operator.name" .) "sa") .Values.serviceAccount.name -}}
{{- $serviceAccountName | trunc 63 | trimSuffix "-"  -}}
{{- end -}}

{{- define "kannika-operator.hash" -}}
{{- $data := . -}}
{{- $json := $data | toJson -}}
{{- $hash := $json | sha256sum | trim -}}
{{- printf "%s" $hash -}}
{{- end -}}

{{/*
Get the imagePullSecrets from the values file or from the global.imagePullSecrets.
The local imagePullSecrets takes precedence over the global imagePullSecrets.
If none are defined, an empty array is returned.
*/}}
{{- define "kannika-operator.imagePullSecrets" -}}
  {{- if .Values.imagePullSecrets -}}
    {{- toYaml .Values.imagePullSecrets -}}
  {{- else if .Values.global.imagePullSecrets -}}
    {{- toYaml .Values.global.imagePullSecrets -}}
  {{- else -}}
    []
  {{- end -}}
{{- end -}}

{{- define "kannika-operator.eventGatewayServiceUrl" -}}
{{- if .Values.config.eventGateway.enabled }}
  {{- $name := default .Values.config.eventGateway.service.name "event-gateway" }}
  {{- $namespace := default .Values.config.eventGateway.service.namespace .Release.Namespace }}
  {{- $port := default .Values.config.eventGateway.service.port 8082 }}
  {{- printf "http://%s.%s.svc.cluster.local:%d" $name $namespace $port }}
{{- else -}}
  {{- printf "" }}
{{- end -}}
{{- end -}}


{{/*
Get the replicaCount from the values file or default to 1.
Minimum 0 and maximum 1.
*/}}
{{- define "kannika-operator.replicaCount" -}}
  {{- if not (regexMatch "^[0-9]+$" (printf "%v" .Values.replicaCount)) -}}
    {{- fail "replicaCount must be an integer" -}}
  {{- end -}}

  {{ $replicaCount := .Values.replicaCount | int }}
  {{- if gt $replicaCount 1 -}}
    {{- fail "replicaCount must be 0 or 1" -}}
  {{- end -}}
  {{- if lt $replicaCount 0 -}}
    {{- fail "replicaCount must be 0 or 1" -}}
  {{- end -}}

  {{- $replicaCount }}

{{- end -}}

{{/*
  Get the namespace where the Kannika Armory resources will live.
  This is the namespace that the operator will watch for Kannika Armory resources.
  Uses `.Values.global.kubernetes.namespace` if it is set, otherwise uses the installation namespace.
*/}}
{{- define "kannika-operator.kubernetesNamespace" -}}
  {{- default .Release.Namespace .Values.global.kubernetes.namespace -}}
{{- end -}}

{{/*
  Fetches the rules from a Role definition in the `roles/` folder.

  Must be called with a list of two arguments:
  1. The chart context
  2. The role name

  Example:
  ```yaml
  rules:
  {{ include "kannika-operator.rules" (list $ "resource-manager") | indent 2 }}
  ```

  An array of rules is returned in YAML format.
*/}}
{{- define "kannika-operator.rules" -}}
  {{- $ := index . 0 }}
  {{- $roleArg := required "role is required" (index . 1) }}

  {{- $fileName := printf "roles/%s.yaml" $roleArg -}}
  {{- $role := $.Files.Get $fileName | fromYaml -}}

  {{- $rulesNotFoundErr := printf "could not find rules in %s" $fileName -}}
  {{- $rules := required $rulesNotFoundErr $role.rules -}}
  {{- toYaml $rules -}}
{{- end -}}
