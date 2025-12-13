{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kannika-console.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kannika-console.chart" -}}
{{- $name := required "appName is required" .Chart.Name -}}
{{- $version := required "appVersion is required" .Chart.AppVersion -}}
{{- printf "%s-%s" $name $version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Base labels
*/}}
{{- define "kannika-console.baseLabels" -}}
app.kubernetes.io/name: {{ include "kannika-console.name" . }}
helm.sh/chart: {{ include "kannika-console.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: api
app.kubernetes.io/part-of: "kannika"
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Base labels plus version label
*/}}
{{- define "kannika-console.labels" -}}
{{- include "kannika-console.baseLabels" . }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
{{- end -}}

{{/*
{{- end -}}

{{/*
Base labels plus version label
*/}}
{{- define "kannika-console.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kannika-console.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use for the main application
*/}}
{{- define "kannika-console.serviceAccount" -}}
{{- $serviceAccountName :=  default (printf "%s-%s" (include "kannika-console.name" .) "sa") .Values.serviceAccount.name -}}
{{- $serviceAccountName | trunc 63 | trimSuffix "-"  -}}
{{- end -}}

{{- define "kannika-console.hash" -}}
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
{{- define "kannika-console.imagePullSecrets" -}}
  {{- if .Values.imagePullSecrets -}}
    {{- toYaml .Values.imagePullSecrets -}}
  {{- else if .Values.global.imagePullSecrets -}}
    {{- toYaml .Values.global.imagePullSecrets -}}
  {{- else -}}
    []
  {{- end -}}
{{- end -}}

{{- define "kannika-console.replicaCount" -}}
  {{- if not (regexMatch "^[0-9]+$" (printf "%v" .Values.replicaCount)) -}}
    {{- fail "replicaCount must be an integer" -}}
  {{- else -}}
    {{ .Values.replicaCount | int }}
  {{- end -}}
{{- end -}}
