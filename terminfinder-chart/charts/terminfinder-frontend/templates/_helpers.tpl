{{/*
Expand the name of the chart.
*/}}
{{- define "terminfinder-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "terminfinder-frontend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "terminfinder-frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "terminfinder-frontend.labels" -}}
helm.sh/chart: {{ include "terminfinder-frontend.chart" . }}
{{ include "terminfinder-frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "terminfinder-frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "terminfinder-frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "terminfinder-frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "terminfinder-frontend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Run tpl on an input value

Takes 2 input parameters as list
Parameter 1: $ (Root context, required by tpl)
Parameter 2: Value to run tpl on
*/}}
{{- define "terminfinder-frontend.value-tpl" -}}
  {{- $ := index . 0 }}
  {{- $tpl := index . 1 -}}
  {{- /* only call tpl if there is at least one template expression */ -}}
  {{- if contains "{{" $tpl -}}
    {{- tpl $tpl $ }}
  {{- else -}}
    {{- $tpl -}}
  {{- end -}}
{{- end -}}
