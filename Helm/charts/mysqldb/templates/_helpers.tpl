{{/*
Expand the name of the chart.
*/}}
{{- define "mysqldb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mysqldb.fullname" -}}
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
{{- define "mysqldb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create configmap name.
*/}}
{{- define "mysqldb.configmapName" -}}
{{- printf "%s-%s" .Chart.Name "config" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create secret name.
*/}}
{{- define "mysqldb.secretName" -}}
{{- printf "%s-%s" .Chart.Name "secret" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create headless service name.
*/}}
{{- define "mysqldb.headlessSvcName" -}}
{{- printf "%s-%s" .Chart.Name "headless-svc" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create clusterIP service name.
*/}}
{{- define "mysqldb.svcName" -}}
{{- printf "%s-%s" .Chart.Name "read-svc" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mysqldb.labels" -}}
helm.sh/chart: {{ include "mysqldb.chart" . }}
{{ include "mysqldb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mysqldb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mysqldb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mysqldb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mysqldb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
