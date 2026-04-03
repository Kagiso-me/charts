{{/*
Expand the name of the chart.
*/}}
{{- define "redis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "redis.fullname" -}}
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
Master statefulset name.
*/}}
{{- define "redis.master.fullname" -}}
{{- printf "%s-master" (include "redis.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Headless service name for the master (used for stable pod DNS).
*/}}
{{- define "redis.master.svc.headless" -}}
{{- printf "%s-hl" (include "redis.master.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "redis.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Namespace: allow override via .Values.namespaceOverride.
*/}}
{{- define "redis.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "redis.labels" -}}
helm.sh/chart: {{ include "redis.chart" . }}
{{ include "redis.selectorLabels" . }}
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
{{- define "redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redis.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Master-specific selector labels.
*/}}
{{- define "redis.master.selectorLabels" -}}
{{ include "redis.selectorLabels" . }}
app.kubernetes.io/component: master
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "redis.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "redis.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Secret name for auth credentials.
*/}}
{{- define "redis.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "redis.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve the container image, applying the global registry override if set.
*/}}
{{- define "redis.image" -}}
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
Affinity preset helper.
Renders a podAffinity or podAntiAffinity block for soft/hard presets.
Usage: {{ include "redis.affinityPreset" (dict "preset" .Values.master.podAntiAffinityPreset "context" $) }}
*/}}
{{- define "redis.affinityPreset" -}}
{{- if eq .preset "soft" }}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchLabels:
          {{- include "redis.master.selectorLabels" .context | nindent 10 }}
      topologyKey: kubernetes.io/hostname
{{- else if eq .preset "hard" }}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
        {{- include "redis.master.selectorLabels" .context | nindent 8 }}
    topologyKey: kubernetes.io/hostname
{{- end }}
{{- end }}

{{/*
Resolve the metrics exporter image, applying the global registry override if set.
*/}}
{{- define "redis.metrics.image" -}}
{{- $registry := coalesce .Values.global.imageRegistry .Values.metrics.image.registry }}
{{- $repository := .Values.metrics.image.repository }}
{{- $tag := .Values.metrics.image.tag }}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- else }}
{{- printf "%s:%s" $repository $tag }}
{{- end }}
{{- end }}

{{/*
Render imagePullSecrets — merges global and local lists.
*/}}
{{- define "redis.imagePullSecrets" -}}
{{- $pullSecrets := concat .Values.global.imagePullSecrets .Values.image.pullSecrets | uniq }}
{{- if $pullSecrets }}
imagePullSecrets:
{{- range $pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
StorageClass for PVCs.
*/}}
{{- define "redis.storageClass" -}}
{{- $storageClass := coalesce .Values.master.persistence.storageClass .Values.global.storageClass }}
{{- if $storageClass }}
storageClassName: {{ $storageClass | quote }}
{{- end }}
{{- end }}

{{/*
Return true if a password secret should be created.
*/}}
{{- define "redis.createSecret" -}}
{{- if and .Values.auth.enabled (not .Values.auth.existingSecret) }}
{{- true }}
{{- end }}
{{- end }}

{{/*
Redis port.
*/}}
{{- define "redis.port" -}}
{{- .Values.master.service.port | default 6379 }}
{{- end }}
