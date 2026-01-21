{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kannika-api.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kannika-api.chart" -}}
{{- $name := required "appName is required" .Chart.Name -}}
{{- $version := required "appVersion is required" .Chart.AppVersion -}}
{{- printf "%s-%s" $name $version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Base labels
*/}}
{{- define "kannika-api.baseLabels" -}}
app.kubernetes.io/name: {{ include "kannika-api.name" . }}
helm.sh/chart: {{ include "kannika-api.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: api
app.kubernetes.io/part-of: "kannika"
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Base labels plus version label
*/}}
{{- define "kannika-api.labels" -}}
{{- include "kannika-api.baseLabels" . }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
{{- end -}}

{{/*
{{- end -}}

{{/*
Base labels plus version label
*/}}
{{- define "kannika-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kannika-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use for the main application
*/}}
{{- define "kannika-api.serviceAccount" -}}
{{- $serviceAccountName :=  default (printf "%s-%s" (include "kannika-api.name" .) "sa") .Values.serviceAccount.name -}}
{{- $serviceAccountName | trunc 63 | trimSuffix "-"  -}}
{{- end -}}

{{- define "kannika-api.hash" -}}
{{- $data := . -}}
{{- $json := $data | toJson -}}
{{- $hash := $json | sha256sum | trim -}}
{{- printf "%s" $hash -}}
{{- end -}}

{{/*
  Get the namespace where the Kannika Armory resources will live.
  This is the namespace that the API will watch for Kannika Armory resources.
  Uses `.Values.global.kubernetes.namespace` if it is set, otherwise uses `default`.
*/}}
{{- define "kannika-api.kubernetesNamespace" -}}
{{- if .Values.config.kubernetes.namespace }}
{{- fail "The `api.config.kubernetes.namespace` parameter is no longer supported. Use `global.kubernetes.namespace` instead." -}}
{{- else if .Values.global.kubernetes.namespace -}}
  {{- .Values.global.kubernetes.namespace -}}
{{- else -}}
    {{- default .Release.Namespace .Values.global.kubernetes.namespace -}}
{{- end -}}
{{- end -}}

{{- define "kannika-api.dataDirectory" -}}
{{- if .Values.config.data.directory -}}
     {{- .Values.config.data.directory -}}
  {{- else -}}
    {{- default "/var/lib/kannika" -}}
  {{- end -}}
{{- end -}}


{{- define "kannika-api.dataPvcName" -}}
{{- $dataPvcName := default (printf "%s-%s" (include "kannika-api.name" .) "data") .Values.storage.persistentVolume.nameOverwrite -}}
{{- $dataPvcName | trunc 63 | trimSuffix "-"  -}}
{{- end -}}

{{- define "kannika-api.deploymentDataVolume" -}}
{{- if .Values.storage.persistentVolume.enabled -}}
- name: kannika-data-volume
  persistentVolumeClaim:
    claimName: {{ include "kannika-api.dataPvcName" . }}
{{- else if .Values.storage.hostPath }}
- name: kannika-data-volume
  hostPath:
    path: {{ .Values.storage.hostPath | quote }}
{{- else -}}
- name: kannika-data-volume
  emptyDir: {}
{{- end -}}
{{- end -}}

{{/*
Get the imagePullSecrets from the values file or from the global.imagePullSecrets.
The local imagePullSecrets takes precedence over the global imagePullSecrets.
If none are defined, an empty array is returned.
*/}}
{{- define "kannika-api.imagePullSecrets" -}}
  {{- if .Values.imagePullSecrets -}}
    {{- toYaml .Values.imagePullSecrets -}}
  {{- else if .Values.global.imagePullSecrets -}}
    {{- toYaml .Values.global.imagePullSecrets -}}
  {{- else -}}
    []
  {{- end -}}
{{- end -}}


{{- define "kannika-api.operatorServiceUrl" -}}
{{- if .Values.config.operatorService.enabled }}
  {{- $name := .Values.config.operatorService.name | default "kannika-operator" }}
  {{- $namespace := .Values.config.operatorService.namespace | default .Release.Namespace }}
  {{- $port := .Values.config.operatorService.port | default 8080 | int }}
  {{- printf "http://%s.%s.svc.cluster.local:%d" $name $namespace $port }}
{{- else -}}
  {{- printf "" }}
{{- end -}}
{{- end -}}

{{/*
Get the replicas from the values file or default to 1.
Minimum 0 and maximum 1.
*/}}
{{- define "kannika-api.replicaCount" -}}
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
  Fetches the rules from a Role definition in the `roles/` folder.

  Must be called with a list of two arguments:
  1. The chart context
  2. The role name

  Example:
  ```yaml
  rules:
  {{ include "kannika-api.rules" (list $ "resource-manager") | indent 2 }}
  ```

  An array of rules is returned in YAML format.
*/}}
{{- define "kannika-api.rules" -}}
  {{- $ := index . 0 }}
  {{- $roleArg := required "role is required" (index . 1) }}

  {{- $fileName := printf "roles/%s.yaml" $roleArg -}}
  {{- $role := $.Files.Get $fileName | fromYaml -}}

  {{- $rulesNotFoundErr := printf "could not find rules in %s" $fileName -}}
  {{- $rules := required $rulesNotFoundErr $role.rules -}}
  {{- toYaml $rules -}}
{{- end -}}

{{- define "kannika-api.basicAuthEnvVars" -}}
{{- if .Values.config.security.enabled }}
  {{- $secretName := .Values.config.security.secret.name | default (include "kannika-api.name" $) -}}
  {{- $userKey := .Values.config.security.secret.usernameKey | default "username" -}}
  {{- $passKey := .Values.config.security.secret.passwordKey | default "password" -}}
  {{- if or .Values.config.security.secret.create .Values.config.security.secret.name }}
- name: KANNIKA_SECURITY_BASIC_AUTH_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ $userKey }}
- name: KANNIKA_SECURITY_BASIC_AUTH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ $passKey }}
  {{- else }}
    {{- if .Values.config.security.username }}
- name: KANNIKA_SECURITY_BASIC_AUTH_USERNAME
  value: {{ .Values.config.security.username | quote }}
    {{- end }}
    {{- if .Values.config.security.password }}
- name: KANNIKA_SECURITY_BASIC_AUTH_PASSWORD
  value: {{ .Values.config.security.password | quote }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}
