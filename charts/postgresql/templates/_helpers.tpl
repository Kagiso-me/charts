{{/*
Expand the name of the chart.
*/}}
{{- define "postgresql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncate at 63 chars because some Kubernetes name fields are limited to 63 characters.
*/}}
{{- define "postgresql.fullname" -}}
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
Primary statefulset name.
*/}}
{{- define "postgresql.primary.fullname" -}}
{{- printf "%s-%s" (include "postgresql.fullname" .) .Values.primary.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Headless service name for the primary (used for stable pod DNS).
*/}}
{{- define "postgresql.primary.svc.headless" -}}
{{- printf "%s-hl" (include "postgresql.primary.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgresql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Namespace: allow override via .Values.namespaceOverride.
*/}}
{{- define "postgresql.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "postgresql.labels" -}}
helm.sh/chart: {{ include "postgresql.chart" . }}
{{ include "postgresql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels — used by Service selectors and StatefulSet matchLabels.
*/}}
{{- define "postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Primary-specific selector labels (adds component=primary so you can target just the primary).
*/}}
{{- define "postgresql.primary.selectorLabels" -}}
{{ include "postgresql.selectorLabels" . }}
app.kubernetes.io/component: primary
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "postgresql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "postgresql.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Secret name for auth credentials.
*/}}
{{- define "postgresql.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "postgresql.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the container image, applying the global registry override if set.
Usage: {{ include "postgresql.image" . }}
*/}}
{{- define "postgresql.image" -}}
{{- $registry := coalesce .Values.global.imageRegistry .Values.image.registry }}
{{- $repository := .Values.image.repository }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- else }}
{{- printf "%s:%s" $repository $tag }}
{{- end }}
{{- end }}

{{/*
Render imagePullSecrets — merges global and local lists.
*/}}
{{- define "postgresql.imagePullSecrets" -}}
{{- $pullSecrets := concat .Values.global.imagePullSecrets .Values.image.pullSecrets | uniq }}
{{- if $pullSecrets }}
imagePullSecrets:
{{- range $pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
StorageClass for PVCs: primary.persistence.storageClass → global.storageClass → cluster default.
Returning "-" disables dynamic provisioning (uses cluster default when empty).
*/}}
{{- define "postgresql.storageClass" -}}
{{- $storageClass := coalesce .Values.primary.persistence.storageClass .Values.global.storageClass }}
{{- if $storageClass }}
storageClassName: {{ $storageClass | quote }}
{{- end }}
{{- end }}

{{/*
Return true if a password secret should be created (i.e. no existingSecret).
*/}}
{{- define "postgresql.createSecret" -}}
{{- if not .Values.auth.existingSecret }}
{{- true }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port.
*/}}
{{- define "postgresql.port" -}}
{{- .Values.primary.service.port | default 5432 }}
{{- end }}
