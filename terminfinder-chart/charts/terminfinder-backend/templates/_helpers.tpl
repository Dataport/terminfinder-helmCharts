{{/*
Expand the name of the chart.
*/}}
{{- define "terminfinder-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "terminfinder-backend.fullname" -}}
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
{{- define "terminfinder-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "terminfinder-backend.labels" -}}
helm.sh/chart: {{ include "terminfinder-backend.chart" . }}
{{ include "terminfinder-backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "terminfinder-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "terminfinder-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "terminfinder-backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "terminfinder-backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if external db and postgres are not used at the same time
*/}}
{{- define "terminfinder-backend.check-database-values" -}}
{{- if and .Values.externalDatabase.enabled .Values.postgresql.enabled }}
{{- fail "It's not possible to use an external database and a Postgres DB subchart at the same time." -}}
{{- end }}
{{- if and (not .Values.externalDatabase.enabled) (not .Values.postgresql.enabled) }}
{{- (printf "no database is enabled check-database-values %b" .Values.externalDatabase.enabled) | fail }}
{{- end }}
{{- end }}

{{- define "terminfinder-backend.database-server-address" -}}
{{- include "terminfinder-backend.check-database-values" . }}
{{- if .Values.externalDatabase.enabled }}
{{- .Values.externalDatabase.address }}
{{- else if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else }}
{{- fail "no database is enabled database-server-address" }}
{{- end }}
{{- end }}

{{- define "terminfinder-backend.database-name" -}}
{{- include "terminfinder-backend.check-database-values" . }}
{{- if .Values.externalDatabase.enabled }}
{{- .Values.externalDatabase.database }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- fail "no database is enabled database-name" }}
{{- end }}
{{- end }}

{{- define "terminfinder-backend.database-port" -}}
{{- include "terminfinder-backend.check-database-values" . }}
{{- if .Values.externalDatabase.enabled }}
{{- .Values.externalDatabase.port | quote }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.primary.service.ports.postgresql | quote }}
{{- else }}
{{- fail "no database is enabled database-port" }}
{{- end }}
{{- end }}

{{- define "terminfinder-backend.database-username" -}}
{{- include "terminfinder-backend.check-database-values" . }}
{{- if .Values.externalDatabase.enabled }}
{{- .Values.externalDatabase.username }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- fail "no database is enabled database-username" }}
{{- end }}
{{- end }}

{{- define "terminfinder-backend.database-existingSecret" -}}
{{- include "terminfinder-backend.check-database-values" . }}
{{- if .Values.externalDatabase.enabled }}
{{- .Values.externalDatabase.existingSecret }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.existingSecret }}
{{- else }}
{{- fail "no database is enabled database-existingSecret" }}
{{- end }}
{{- end }}

{{- define "terminfinder-backend.database-userPasswordKey" -}}
{{- include "terminfinder-backend.check-database-values" . }}
{{- if .Values.externalDatabase.enabled }}
{{- .Values.externalDatabase.secretKeys.userPasswordKey }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.secretKeys.userPasswordKey }}
{{- else }}
{{- fail "no database is enabled database-userPasswordKey" }}
{{- end }}
{{- end }}
