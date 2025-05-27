-- Insert node that defaults to value of another insert node
local function i_rep(jump_index, node_reference)
	return d(jump_index, function(args)
		return sn(nil, {
			i(1, args[1]),
		})
	end, { node_reference })
end

return {
	s(
		"ns",
		fmta(
			[[
                apiVersion: v1
                kind: Namespace
                metadata:
                  name: <name>
            ]],
			{
				name = i(1),
			}
		)
	),
	s(
		"depl",
		fmta(
			[[
                apiVersion: apps/v1
                kind: Deployment
                metadata:
                  name: <name>
                  namespace: <namespace>
                  labels:
                    app.kubernetes.io/name: <depl_app_name>
                    app.kubernetes.io/instance: <depl_app_instance>
                spec:
                  replicas: <replicas>
                  selector:
                    matchLabels:
                      app.kubernetes.io/name: <selector_app_name>
                      app.kubernetes.io/instance: <selector_app_instance>
                  template:
                    metadata:
                      labels:
                        app.kubernetes.io/name: <pod_app_name>
                        app.kubernetes.io/instance: <pod_app_instance>
                    spec:
                      containers:
                        - name: <container_name>
                          image: <container_image>
            ]],
			{
				name = i(1),
				namespace = i_rep(2, 1),
				depl_app_name = i_rep(3, 1),
				depl_app_instance = i_rep(4, 3),
				replicas = i(5),
				selector_app_name = rep(3),
				selector_app_instance = rep(4),
				pod_app_name = rep(3),
				pod_app_instance = rep(4),
				container_name = i(6),
				container_image = i(7),
			}
		)
	),
	s(
		"sts",
		fmta(
			[[
                apiVersion: apps/v1
                kind: StatefulSet
                metadata:
                  name: <name>
                  namespace: <namespace>
                  labels:
                    app.kubernetes.io/name: <sts_app_name>
                    app.kubernetes.io/instance: <sts_app_instance>
                spec:
                  replicas: <replicas>
                  serviceName: <service_name>
                  selector:
                    matchLabels:
                      app.kubernetes.io/name: <selector_app_name>
                      app.kubernetes.io/instance: <selector_app_instance>
                  volumeClaimTemplates:
                    - metadata:
                        name: <volume_name>
                      spec:
                        accessModes: [ "<volume_access_mode>" ]
                        storageClassName: "<volume_storage_class>"
                        resources:
                          requests:
                            storage: <volume_storage_request>
                  template:
                    metadata:
                      labels:
                        app.kubernetes.io/name: <pod_app_name>
                        app.kubernetes.io/instance: <pod_app_instance>
                    spec:
                      containers:
                        - name: <container_name>
                          image: <container_image>
            ]],
			{
				name = i(1),
				namespace = i_rep(2, 1),
				sts_app_name = i_rep(3, 1),
				sts_app_instance = i_rep(4, 3),
				replicas = i(5),
				service_name = rep(1),
				selector_app_name = rep(3),
				selector_app_instance = rep(4),
				volume_name = rep(1),
				volume_access_mode = c(6, {
					t("ReadWriteOnce"),
					t("ReadWriteMany"),
					t("ReadOnlyMany"),
					t("ReadWriteOncePod"),
				}),
				volume_storage_class = i(7, "freenas-api-iscsi-csi"),
				volume_storage_request = i(8, "1Gi"),
				pod_app_name = rep(3),
				pod_app_instance = rep(4),
				container_name = i(9),
				container_image = i(10),
			}
		)
	),
	s(
		"svc",
		fmta(
			[[
                apiVersion: v1
                kind: Service
                metadata:
                  name: <name>
                  namespace: <namespace>
                  labels:
                    app.kubernetes.io/name: <svc_app_name>
                    app.kubernetes.io/instance: <svc_app_instance>
                spec:
                  type: <svc_type>
                  selector:
                    app.kubernetes.io/name: <selector_app_name>
                    app.kubernetes.io/instance: <selector_app_instance>
                  ports:
                    - name: <port_name>
                      port: <port>
                      targetPort: <port_target>
                      protocol: <port_proto>
            ]],
			{
				name = i(1),
				namespace = i_rep(2, 1),
				svc_app_name = i_rep(3, 1),
				svc_app_instance = i_rep(4, 3),
				svc_type = c(5, {
					t("ClusterIP"),
					t("LoadBalancer"),
					t("NodePort"),
					t("ExternalName"),
				}),
				selector_app_name = rep(3),
				selector_app_instance = rep(4),
				port_name = i(6),
				port = i(7),
				port_target = i_rep(8, 7),
				port_proto = c(9, {
					t("TCP"),
					t("UDP"),
				}),
			}
		)
	),
	s(
		"ingress",
		fmta(
			[[
                apiVersion: networking.k8s.io/v1
                kind: Ingress
                metadata:
                  name: <name>
                  namespace: <namespace>
                  labels:
                    app.kubernetes.io/name: <ingress_app_name>
                    app.kubernetes.io/instance: <ingress_app_instance>
                spec:
                  ingressClassName: <class_name>
                  rules:
                    - host: <host>
                      http:
                        paths:
                          - path: <path>
                            pathType: <path_type>
                            backend:
                              service:
                                name: <svc_name>
                                port:
                                  number: <svc_port>
            ]],
			{
				name = i(1),
				namespace = i_rep(2, 1),
				ingress_app_name = i_rep(3, 1),
				ingress_app_instance = i_rep(4, 3),
				class_name = i(5),
				host = i(6),
				path = i(7),
				path_type = c(8, {
					t("Prefix"),
					t("Exact"),
					t("ImplementationSpecific"),
				}),
				svc_name = i(9),
				svc_port = i(10),
			}
		)
	),
	s(
		"secret",
		fmta(
			[[
                apiVersion: v1
                kind: Secret
                metadata:
                  name: <name>
                  namespace: <namespace>
                <dataType>:
            ]],
			{
				name = i(1),
				namespace = i(2),
				dataType = c(3, {
					t("stringData"),
					t("data"),
				}),
			}
		)
	),
	s(
		"cfgmap",
		fmta(
			[[
                apiVersion: v1
                kind: ConfigMap
                metadata:
                  name: <name>
                  namespace: <namespace>
                data:
            ]],
			{
				name = i(1),
				namespace = i(2),
			}
		)
	),
	s(
		"pvc",
		fmta(
			[[
                apiVersion: v1
                kind: PersistentVolumeClaim
                metadata:
                  name: <name>
                  namespace: <namespace>
                spec:
                  accessModes:
                    - <access_mode>
                  volumeMode: <volume_mode>
                  resources:
                    requests:
                      storage: <storage>
                  storageClassName: <storage_class>
            ]],
			{
				name = i(1),
				namespace = i(2),
				access_mode = c(3, {
					t("ReadWriteOnce"),
					t("ReadWriteMany"),
					t("ReadOnlyMany"),
					t("ReadWriteOncePod"),
				}),
				volume_mode = c(4, {
					t("Filesystem"),
					t("Block"),
				}),
				storage = i(5, "1Gi"),
				storage_class = i(6, "freenas-api-iscsi-csi"),
			}
		)
	),
	s(
		"hr",
		fmta(
			[[
                # yaml-language-server: $schema=https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/helm.toolkit.fluxcd.io/helmrelease_v2beta1.json
                apiVersion: helm.toolkit.fluxcd.io/v2beta1
                kind: HelmRelease
                metadata:
                  name: <name>
                  namespace: flux-system
                spec:
                  interval: 30m
                  targetNamespace: <namespace>
                  chart:
                    spec:
                      chart: <chart>
                      version: <version>
                      sourceRef:
                        kind: HelmRepository
                        name: <repo>
                        namespace: <repo_namespace>
                      interval: 30m
                  install:
                    crds: CreateReplace
                  upgrade:
                    crds: CreateReplace
                  values:
                    <values>
            ]],
			{
				name = i(1),
				namespace = i_rep(2, 1),
				chart = i_rep(3, 1),
				version = i(4),
				repo = i_rep(5, 1),
				repo_namespace = i(6, "flux-system"),
				values = i(7),
			}
		)
	),
	s(
		"helmrepo",
		fmta(
			[[
                # yaml-language-server: $schema=https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/source.toolkit.fluxcd.io/helmrepository_v1beta2.json
                apiVersion: source.toolkit.fluxcd.io/v1beta2
                kind: HelmRepository
                metadata:
                  name: <name>
                  namespace: flux-system
                spec:
                  interval: 30m
                  url: <url>
                  timeout: 3m
            ]],
			{
				name = i(1),
				url = i(2),
			}
		)
	),
}
