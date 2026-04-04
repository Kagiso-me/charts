{{/*
Expand the name of the chart.
*/}}
{{- define "authentik.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "authentik.fullname" -}}
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
Create chart label value.
*/}}
{{- define "authentik.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "authentik.labels" -}}
helm.sh/chart: {{ include "authentik.chart" . }}
{{ include "authentik.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — shared base, refined per component.
*/}}
{{- define "authentik.selectorLabels" -}}
app.kubernetes.io/name: {{ include "authentik.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Server selector labels.
*/}}
{{- define "authentik.server.selectorLabels" -}}
{{ include "authentik.selectorLabels" . }}
app.kubernetes.io/component: server
{{- end }}

{{/*
Worker selector labels.
*/}}
{{- define "authentik.worker.selectorLabels" -}}
{{ include "authentik.selectorLabels" . }}
app.kubernetes.io/component: worker
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "authentik.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "authentik.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolved image — registry/repository:tag.
Registry precedence: global.imageRegistry > image.registry.
Tag defaults to appVersion.
*/}}
{{- define "authentik.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.image.repository $tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}
{{- end }}

{{/*
Affinity preset helper.
Usage: {{ include "authentik.affinityPreset" (dict "preset" .Values.server.podAntiAffinityPreset "type" "anti" "context" . "component" "server") }}
*/}}
{{- define "authentik.affinityPreset" -}}
{{- $preset := .preset -}}
{{- $type := .type -}}
{{- $component := .component -}}
{{- $ctx := .context -}}
{{- if and $preset (ne $preset "") -}}
{{- if eq $type "anti" -}}
{{- if eq $preset "hard" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: {{ include "authentik.name" $ctx }}
          app.kubernetes.io/instance: {{ $ctx.Release.Name }}
          app.kubernetes.io/component: {{ $component }}
      topologyKey: kubernetes.io/hostname
{{- else if eq $preset "soft" }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: {{ include "authentik.name" $ctx }}
            app.kubernetes.io/instance: {{ $ctx.Release.Name }}
            app.kubernetes.io/component: {{ $component }}
        topologyKey: kubernetes.io/hostname
{{- end -}}
{{- else if eq $type "affinity" -}}
{{- if eq $preset "hard" }}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: {{ include "authentik.name" $ctx }}
          app.kubernetes.io/instance: {{ $ctx.Release.Name }}
          app.kubernetes.io/component: {{ $component }}
      topologyKey: kubernetes.io/hostname
{{- else if eq $preset "soft" }}
podAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: {{ include "authentik.name" $ctx }}
            app.kubernetes.io/instance: {{ $ctx.Release.Name }}
            app.kubernetes.io/component: {{ $component }}
        topologyKey: kubernetes.io/hostname
{{- end -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Node affinity preset helper.
Usage: {{ include "authentik.nodeAffinityPreset" (dict "preset" .Values.server.nodeAffinityPreset "context" .) }}
*/}}
{{- define "authentik.nodeAffinityPreset" -}}
{{- $p := .preset -}}
{{- if and $p.type (ne $p.type "") $p.key (ne $p.key "") $p.values -}}
{{- if eq $p.type "hard" }}
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
          - key: {{ $p.key }}
            operator: In
            values:
              {{- range $p.values }}
              - {{ . | quote }}
              {{- end }}
{{- else if eq $p.type "soft" }}
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      preference:
        matchExpressions:
          - key: {{ $p.key }}
            operator: In
            values:
              {{- range $p.values }}
              - {{ . | quote }}
              {{- end }}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Render the name of the Secret holding AUTHENTIK_* env vars.
Returns existingSecret.secretName if set, otherwise the chart-managed secret name.
*/}}
{{- define "authentik.secretName" -}}
{{- if .Values.existingSecret.secretName -}}
{{- .Values.existingSecret.secretName -}}
{{- else -}}
{{- printf "%s-config" (include "authentik.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Global image pull secrets merged with chart-level pullSecrets.
*/}}
{{- define "authentik.imagePullSecrets" -}}
{{- $pullSecrets := .Values.global.imagePullSecrets -}}
{{- if $pullSecrets }}
imagePullSecrets:
  {{- range $pullSecrets }}
  - name: {{ . }}
  {{- end }}
{{- end }}
{{- end }}
