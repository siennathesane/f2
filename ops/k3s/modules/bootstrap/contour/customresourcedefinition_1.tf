# Generated from Kubernetes CustomResourceDefinition: contourdeployments.projectcontour.io
# API Version: apiextensions.k8s.io/v1
# Type: Custom Resource (kubernetes_manifest)

resource "kubernetes_manifest" "customresourcedefinition_contourdeployments_projectcontour_io" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind"       = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.18.0"
      }
      "name" = "contourdeployments.projectcontour.io"
    }
    "spec" = {
      "group" = "projectcontour.io"
      "names" = {
        "kind"     = "ContourDeployment"
        "listKind" = "ContourDeploymentList"
        "plural"   = "contourdeployments"
        "shortNames" = [
          "contourdeploy",
        ]
        "singular" = "contourdeployment"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "name" = "v1alpha1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "ContourDeployment is the schema for a Contour Deployment."
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type"        = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type"        = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = <<-EOT
                  ContourDeploymentSpec specifies options for how a Contour
                  instance should be provisioned.
                  EOT
                  "properties" = {
                    "contour" = {
                      "description" = <<-EOT
                      Contour specifies deployment-time settings for the Contour
                      part of the installation, i.e. the xDS server/control plane
                      and associated resources, including things like replica count
                      for the Deployment, and node placement constraints for the pods.
                      EOT
                      "properties" = {
                        "deployment" = {
                          "description" = "Deployment describes the settings for running contour as a `Deployment`."
                          "properties" = {
                            "replicas" = {
                              "description" = "Replicas is the desired number of replicas."
                              "format"      = "int32"
                              "minimum"     = 0
                              "type"        = "integer"
                            }
                            "strategy" = {
                              "description" = "Strategy describes the deployment strategy to use to replace existing pods with new pods."
                              "properties" = {
                                "rollingUpdate" = {
                                  "description" = <<-EOT
                                  Rolling update config params. Present only if DeploymentStrategyType =
                                  RollingUpdate.
                                  EOT
                                  "properties" = {
                                    "maxSurge" = {
                                      "anyOf" = [
                                        {
                                          "type" = "integer"
                                        },
                                        {
                                          "type" = "string"
                                        },
                                      ]
                                      "description"                = <<-EOT
                                      The maximum number of pods that can be scheduled above the desired number of
                                      pods.
                                      Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%).
                                      This can not be 0 if MaxUnavailable is 0.
                                      Absolute number is calculated from percentage by rounding up.
                                      Defaults to 25%.
                                      Example: when this is set to 30%, the new ReplicaSet can be scaled up immediately when
                                      the rolling update starts, such that the total number of old and new pods do not exceed
                                      130% of desired pods. Once old pods have been killed,
                                      new ReplicaSet can be scaled up further, ensuring that total number of pods running
                                      at any time during the update is at most 130% of desired pods.
                                      EOT
                                      "x-kubernetes-int-or-string" = true
                                    }
                                    "maxUnavailable" = {
                                      "anyOf" = [
                                        {
                                          "type" = "integer"
                                        },
                                        {
                                          "type" = "string"
                                        },
                                      ]
                                      "description"                = <<-EOT
                                      The maximum number of pods that can be unavailable during the update.
                                      Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%).
                                      Absolute number is calculated from percentage by rounding down.
                                      This can not be 0 if MaxSurge is 0.
                                      Defaults to 25%.
                                      Example: when this is set to 30%, the old ReplicaSet can be scaled down to 70% of desired pods
                                      immediately when the rolling update starts. Once new pods are ready, old ReplicaSet
                                      can be scaled down further, followed by scaling up the new ReplicaSet, ensuring
                                      that the total number of pods available at all times during the update is at
                                      least 70% of desired pods.
                                      EOT
                                      "x-kubernetes-int-or-string" = true
                                    }
                                  }
                                  "type" = "object"
                                }
                                "type" = {
                                  "description" = "Type of deployment. Can be \"Recreate\" or \"RollingUpdate\". Default is RollingUpdate."
                                  "type"        = "string"
                                }
                              }
                              "type" = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "disabledFeatures" = {
                          "description" = <<-EOT
                          DisabledFeatures defines an array of resources that will be ignored by
                          contour reconciler.
                          EOT
                          "items" = {
                            "enum" = [
                              "grpcroutes",
                              "tlsroutes",
                              "extensionservices",
                              "backendtlspolicies",
                            ]
                            "type" = "string"
                          }
                          "maxItems" = 42
                          "minItems" = 1
                          "type"     = "array"
                        }
                        "kubernetesLogLevel" = {
                          "description" = <<-EOT
                          KubernetesLogLevel Enable Kubernetes client debug logging with log level. If unset,
                          defaults to 0.
                          EOT
                          "maximum"     = 9
                          "minimum"     = 0
                          "type"        = "integer"
                        }
                        "logLevel" = {
                          "description" = <<-EOT
                          LogLevel sets the log level for Contour
                          Allowed values are "info", "debug".
                          EOT
                          "type"        = "string"
                        }
                        "nodePlacement" = {
                          "description" = "NodePlacement describes node scheduling configuration of Contour pods."
                          "properties" = {
                            "nodeSelector" = {
                              "additionalProperties" = {
                                "type" = "string"
                              }
                              "description" = <<-EOT
                              NodeSelector is the simplest recommended form of node selection constraint
                              and specifies a map of key-value pairs. For the pod to be eligible
                              to run on a node, the node must have each of the indicated key-value pairs
                              as labels (it can have additional labels as well).
                              If unset, the pod(s) will be scheduled to any available node.
                              EOT
                              "type"        = "object"
                            }
                            "tolerations" = {
                              "description" = <<-EOT
                              Tolerations work with taints to ensure that pods are not scheduled
                              onto inappropriate nodes. One or more taints are applied to a node; this
                              marks that the node should not accept any pods that do not tolerate the
                              taints.
                              The default is an empty list.
                              See https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
                              for additional details.
                              EOT
                              "items" = {
                                "description" = <<-EOT
                                The pod this Toleration is attached to tolerates any taint that matches
                                the triple <key,value,effect> using the matching operator <operator>.
                                EOT
                                "properties" = {
                                  "effect" = {
                                    "description" = <<-EOT
                                    Effect indicates the taint effect to match. Empty means match all taint effects.
                                    When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "key" = {
                                    "description" = <<-EOT
                                    Key is the taint key that the toleration applies to. Empty means match all taint keys.
                                    If the key is empty, operator must be Exists; this combination means to match all values and all keys.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "operator" = {
                                    "description" = <<-EOT
                                    Operator represents a key's relationship to the value.
                                    Valid operators are Exists and Equal. Defaults to Equal.
                                    Exists is equivalent to wildcard for value, so that a pod can
                                    tolerate all taints of a particular category.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "tolerationSeconds" = {
                                    "description" = <<-EOT
                                    TolerationSeconds represents the period of time the toleration (which must be
                                    of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
                                    it is not set, which means tolerate the taint forever (do not evict). Zero and
                                    negative values will be treated as 0 (evict immediately) by the system.
                                    EOT
                                    "format"      = "int64"
                                    "type"        = "integer"
                                  }
                                  "value" = {
                                    "description" = <<-EOT
                                    Value is the taint value the toleration matches to.
                                    If the operator is Exists, the value should be empty, otherwise just a regular string.
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "type" = "object"
                              }
                              "type" = "array"
                            }
                          }
                          "type" = "object"
                        }
                        "podAnnotations" = {
                          "additionalProperties" = {
                            "type" = "string"
                          }
                          "description" = <<-EOT
                          PodAnnotations defines annotations to add to the Contour pods.
                          the annotations for Prometheus will be appended or overwritten with predefined value.
                          EOT
                          "type"        = "object"
                        }
                        "replicas" = {
                          "description" = <<-EOT
                          Deprecated: Use `DeploymentSettings.Replicas` instead.
                          Replicas is the desired number of Contour replicas. If if unset,
                          defaults to 2.
                          if both `DeploymentSettings.Replicas` and this one is set, use `DeploymentSettings.Replicas`.
                          EOT
                          "format"      = "int32"
                          "minimum"     = 0
                          "type"        = "integer"
                        }
                        "resources" = {
                          "description" = <<-EOT
                          Compute Resources required by contour container.
                          Cannot be updated.
                          More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                          EOT
                          "properties" = {
                            "claims" = {
                              "description" = <<-EOT
                              Claims lists the names of resources, defined in spec.resourceClaims,
                              that are used by this container.
                              This is an alpha field and requires enabling the
                              DynamicResourceAllocation feature gate.
                              This field is immutable. It can only be set for containers.
                              EOT
                              "items" = {
                                "description" = "ResourceClaim references one entry in PodSpec.ResourceClaims."
                                "properties" = {
                                  "name" = {
                                    "description" = <<-EOT
                                    Name must match the name of one entry in pod.spec.resourceClaims of
                                    the Pod where this field is used. It makes that resource available
                                    inside a container.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "request" = {
                                    "description" = <<-EOT
                                    Request is the name chosen for a request in the referenced claim.
                                    If empty, everything from the claim is made available, otherwise
                                    only the result of this request.
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "name",
                                ]
                                "type" = "object"
                              }
                              "type" = "array"
                              "x-kubernetes-list-map-keys" = [
                                "name",
                              ]
                              "x-kubernetes-list-type" = "map"
                            }
                            "limits" = {
                              "additionalProperties" = {
                                "anyOf" = [
                                  {
                                    "type" = "integer"
                                  },
                                  {
                                    "type" = "string"
                                  },
                                ]
                                "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                "x-kubernetes-int-or-string" = true
                              }
                              "description" = <<-EOT
                              Limits describes the maximum amount of compute resources allowed.
                              More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                              EOT
                              "type"        = "object"
                            }
                            "requests" = {
                              "additionalProperties" = {
                                "anyOf" = [
                                  {
                                    "type" = "integer"
                                  },
                                  {
                                    "type" = "string"
                                  },
                                ]
                                "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                "x-kubernetes-int-or-string" = true
                              }
                              "description" = <<-EOT
                              Requests describes the minimum amount of compute resources required.
                              If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
                              otherwise to an implementation-defined value. Requests cannot exceed Limits.
                              More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                              EOT
                              "type"        = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "watchNamespaces" = {
                          "description" = <<-EOT
                          WatchNamespaces is an array of namespaces. Setting it will instruct the contour instance
                          to only watch this subset of namespaces.
                          EOT
                          "items" = {
                            "description" = <<-EOT
                            Namespace refers to a Kubernetes namespace. It must be a RFC 1123 label.
                            This validation is based off of the corresponding Kubernetes validation:
                            https://github.com/kubernetes/apimachinery/blob/02cfb53916346d085a6c6c7c66f882e3c6b0eca6/pkg/util/validation/validation.go#L187
                            This is used for Namespace name validation here:
                            https://github.com/kubernetes/apimachinery/blob/02cfb53916346d085a6c6c7c66f882e3c6b0eca6/pkg/api/validation/generic.go#L63
                            Valid values include:
                            * "example"
                            Invalid values include:
                            * "example.com" - "." is an invalid character
                            EOT
                            "maxLength"   = 63
                            "minLength"   = 1
                            "pattern"     = "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
                            "type"        = "string"
                          }
                          "maxItems" = 42
                          "minItems" = 1
                          "type"     = "array"
                        }
                      }
                      "type" = "object"
                    }
                    "envoy" = {
                      "description" = <<-EOT
                      Envoy specifies deployment-time settings for the Envoy
                      part of the installation, i.e. the xDS client/data plane
                      and associated resources, including things like the workload
                      type to use (DaemonSet or Deployment), node placement constraints
                      for the pods, and various options for the Envoy service.
                      EOT
                      "properties" = {
                        "baseID" = {
                          "description" = <<-EOT
                          The base ID to use when allocating shared memory regions.
                          if Envoy needs to be run multiple times on the same machine, each running Envoy will need a unique base ID
                          so that the shared memory regions do not conflict.
                          defaults to 0.
                          EOT
                          "format"      = "int32"
                          "minimum"     = 0
                          "type"        = "integer"
                        }
                        "daemonSet" = {
                          "description" = <<-EOT
                          DaemonSet describes the settings for running envoy as a `DaemonSet`.
                          if `WorkloadType` is `Deployment`,it's must be nil
                          EOT
                          "properties" = {
                            "updateStrategy" = {
                              "description" = "Strategy describes the deployment strategy to use to replace existing DaemonSet pods with new pods."
                              "properties" = {
                                "rollingUpdate" = {
                                  "description" = "Rolling update config params. Present only if type = \"RollingUpdate\"."
                                  "properties" = {
                                    "maxSurge" = {
                                      "anyOf" = [
                                        {
                                          "type" = "integer"
                                        },
                                        {
                                          "type" = "string"
                                        },
                                      ]
                                      "description"                = <<-EOT
                                      The maximum number of nodes with an existing available DaemonSet pod that
                                      can have an updated DaemonSet pod during during an update.
                                      Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%).
                                      This can not be 0 if MaxUnavailable is 0.
                                      Absolute number is calculated from percentage by rounding up to a minimum of 1.
                                      Default value is 0.
                                      Example: when this is set to 30%, at most 30% of the total number of nodes
                                      that should be running the daemon pod (i.e. status.desiredNumberScheduled)
                                      can have their a new pod created before the old pod is marked as deleted.
                                      The update starts by launching new pods on 30% of nodes. Once an updated
                                      pod is available (Ready for at least minReadySeconds) the old DaemonSet pod
                                      on that node is marked deleted. If the old pod becomes unavailable for any
                                      reason (Ready transitions to false, is evicted, or is drained) an updated
                                      pod is immediatedly created on that node without considering surge limits.
                                      Allowing surge implies the possibility that the resources consumed by the
                                      daemonset on any given node can double if the readiness check fails, and
                                      so resource intensive daemonsets should take into account that they may
                                      cause evictions during disruption.
                                      EOT
                                      "x-kubernetes-int-or-string" = true
                                    }
                                    "maxUnavailable" = {
                                      "anyOf" = [
                                        {
                                          "type" = "integer"
                                        },
                                        {
                                          "type" = "string"
                                        },
                                      ]
                                      "description"                = <<-EOT
                                      The maximum number of DaemonSet pods that can be unavailable during the
                                      update. Value can be an absolute number (ex: 5) or a percentage of total
                                      number of DaemonSet pods at the start of the update (ex: 10%). Absolute
                                      number is calculated from percentage by rounding up.
                                      This cannot be 0 if MaxSurge is 0
                                      Default value is 1.
                                      Example: when this is set to 30%, at most 30% of the total number of nodes
                                      that should be running the daemon pod (i.e. status.desiredNumberScheduled)
                                      can have their pods stopped for an update at any given time. The update
                                      starts by stopping at most 30% of those DaemonSet pods and then brings
                                      up new DaemonSet pods in their place. Once the new pods are available,
                                      it then proceeds onto other DaemonSet pods, thus ensuring that at least
                                      70% of original number of DaemonSet pods are available at all times during
                                      the update.
                                      EOT
                                      "x-kubernetes-int-or-string" = true
                                    }
                                  }
                                  "type" = "object"
                                }
                                "type" = {
                                  "description" = "Type of daemon set update. Can be \"RollingUpdate\" or \"OnDelete\". Default is RollingUpdate."
                                  "type"        = "string"
                                }
                              }
                              "type" = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "deployment" = {
                          "description" = <<-EOT
                          Deployment describes the settings for running envoy as a `Deployment`.
                          if `WorkloadType` is `DaemonSet`,it's must be nil
                          EOT
                          "properties" = {
                            "replicas" = {
                              "description" = "Replicas is the desired number of replicas."
                              "format"      = "int32"
                              "minimum"     = 0
                              "type"        = "integer"
                            }
                            "strategy" = {
                              "description" = "Strategy describes the deployment strategy to use to replace existing pods with new pods."
                              "properties" = {
                                "rollingUpdate" = {
                                  "description" = <<-EOT
                                  Rolling update config params. Present only if DeploymentStrategyType =
                                  RollingUpdate.
                                  EOT
                                  "properties" = {
                                    "maxSurge" = {
                                      "anyOf" = [
                                        {
                                          "type" = "integer"
                                        },
                                        {
                                          "type" = "string"
                                        },
                                      ]
                                      "description"                = <<-EOT
                                      The maximum number of pods that can be scheduled above the desired number of
                                      pods.
                                      Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%).
                                      This can not be 0 if MaxUnavailable is 0.
                                      Absolute number is calculated from percentage by rounding up.
                                      Defaults to 25%.
                                      Example: when this is set to 30%, the new ReplicaSet can be scaled up immediately when
                                      the rolling update starts, such that the total number of old and new pods do not exceed
                                      130% of desired pods. Once old pods have been killed,
                                      new ReplicaSet can be scaled up further, ensuring that total number of pods running
                                      at any time during the update is at most 130% of desired pods.
                                      EOT
                                      "x-kubernetes-int-or-string" = true
                                    }
                                    "maxUnavailable" = {
                                      "anyOf" = [
                                        {
                                          "type" = "integer"
                                        },
                                        {
                                          "type" = "string"
                                        },
                                      ]
                                      "description"                = <<-EOT
                                      The maximum number of pods that can be unavailable during the update.
                                      Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%).
                                      Absolute number is calculated from percentage by rounding down.
                                      This can not be 0 if MaxSurge is 0.
                                      Defaults to 25%.
                                      Example: when this is set to 30%, the old ReplicaSet can be scaled down to 70% of desired pods
                                      immediately when the rolling update starts. Once new pods are ready, old ReplicaSet
                                      can be scaled down further, followed by scaling up the new ReplicaSet, ensuring
                                      that the total number of pods available at all times during the update is at
                                      least 70% of desired pods.
                                      EOT
                                      "x-kubernetes-int-or-string" = true
                                    }
                                  }
                                  "type" = "object"
                                }
                                "type" = {
                                  "description" = "Type of deployment. Can be \"Recreate\" or \"RollingUpdate\". Default is RollingUpdate."
                                  "type"        = "string"
                                }
                              }
                              "type" = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "extraVolumeMounts" = {
                          "description" = "ExtraVolumeMounts holds the extra volume mounts to add (normally used with extraVolumes)."
                          "items" = {
                            "description" = "VolumeMount describes a mounting of a Volume within a container."
                            "properties" = {
                              "mountPath" = {
                                "description" = <<-EOT
                                Path within the container at which the volume should be mounted.  Must
                                not contain ':'.
                                EOT
                                "type"        = "string"
                              }
                              "mountPropagation" = {
                                "description" = <<-EOT
                                mountPropagation determines how mounts are propagated from the host
                                to container and the other way around.
                                When not set, MountPropagationNone is used.
                                This field is beta in 1.10.
                                When RecursiveReadOnly is set to IfPossible or to Enabled, MountPropagation must be None or unspecified
                                (which defaults to None).
                                EOT
                                "type"        = "string"
                              }
                              "name" = {
                                "description" = "This must match the Name of a Volume."
                                "type"        = "string"
                              }
                              "readOnly" = {
                                "description" = <<-EOT
                                Mounted read-only if true, read-write otherwise (false or unspecified).
                                Defaults to false.
                                EOT
                                "type"        = "boolean"
                              }
                              "recursiveReadOnly" = {
                                "description" = <<-EOT
                                RecursiveReadOnly specifies whether read-only mounts should be handled
                                recursively.
                                If ReadOnly is false, this field has no meaning and must be unspecified.
                                If ReadOnly is true, and this field is set to Disabled, the mount is not made
                                recursively read-only.  If this field is set to IfPossible, the mount is made
                                recursively read-only, if it is supported by the container runtime.  If this
                                field is set to Enabled, the mount is made recursively read-only if it is
                                supported by the container runtime, otherwise the pod will not be started and
                                an error will be generated to indicate the reason.
                                If this field is set to IfPossible or Enabled, MountPropagation must be set to
                                None (or be unspecified, which defaults to None).
                                If this field is not specified, it is treated as an equivalent of Disabled.
                                EOT
                                "type"        = "string"
                              }
                              "subPath" = {
                                "description" = <<-EOT
                                Path within the volume from which the container's volume should be mounted.
                                Defaults to "" (volume's root).
                                EOT
                                "type"        = "string"
                              }
                              "subPathExpr" = {
                                "description" = <<-EOT
                                Expanded path within the volume from which the container's volume should be mounted.
                                Behaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment.
                                Defaults to "" (volume's root).
                                SubPathExpr and SubPath are mutually exclusive.
                                EOT
                                "type"        = "string"
                              }
                            }
                            "required" = [
                              "mountPath",
                              "name",
                            ]
                            "type" = "object"
                          }
                          "type" = "array"
                        }
                        "extraVolumes" = {
                          "description" = "ExtraVolumes holds the extra volumes to add."
                          "items" = {
                            "description" = "Volume represents a named volume in a pod that may be accessed by any container in the pod."
                            "properties" = {
                              "awsElasticBlockStore" = {
                                "description" = <<-EOT
                                awsElasticBlockStore represents an AWS Disk resource that is attached to a
                                kubelet's host machine and then exposed to the pod.
                                Deprecated: AWSElasticBlockStore is deprecated. All operations for the in-tree
                                awsElasticBlockStore type are redirected to the ebs.csi.aws.com CSI driver.
                                More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is the filesystem type of the volume that you want to mount.
                                    Tip: Ensure that the filesystem type is supported by the host operating system.
                                    Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
                                    EOT
                                    "type"        = "string"
                                  }
                                  "partition" = {
                                    "description" = <<-EOT
                                    partition is the partition in the volume that you want to mount.
                                    If omitted, the default is to mount by volume name.
                                    Examples: For volume /dev/sda1, you specify the partition as "1".
                                    Similarly, the volume partition for /dev/sda is "0" (or you can leave the property empty).
                                    EOT
                                    "format"      = "int32"
                                    "type"        = "integer"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly value true will force the readOnly setting in VolumeMounts.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "volumeID" = {
                                    "description" = <<-EOT
                                    volumeID is unique ID of the persistent disk resource in AWS (Amazon EBS volume).
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "volumeID",
                                ]
                                "type" = "object"
                              }
                              "azureDisk" = {
                                "description" = <<-EOT
                                azureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.
                                Deprecated: AzureDisk is deprecated. All operations for the in-tree azureDisk type
                                are redirected to the disk.csi.azure.com CSI driver.
                                EOT
                                "properties" = {
                                  "cachingMode" = {
                                    "description" = "cachingMode is the Host Caching mode: None, Read Only, Read Write."
                                    "type"        = "string"
                                  }
                                  "diskName" = {
                                    "description" = "diskName is the Name of the data disk in the blob storage"
                                    "type"        = "string"
                                  }
                                  "diskURI" = {
                                    "description" = "diskURI is the URI of data disk in the blob storage"
                                    "type"        = "string"
                                  }
                                  "fsType" = {
                                    "default"     = "ext4"
                                    "description" = <<-EOT
                                    fsType is Filesystem type to mount.
                                    Must be a filesystem type supported by the host operating system.
                                    Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "kind" = {
                                    "description" = "kind expected values are Shared: multiple blob disks per storage account  Dedicated: single blob disk per storage account  Managed: azure managed data disk (only in managed availability set). defaults to shared"
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "default"     = false
                                    "description" = <<-EOT
                                    readOnly Defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                }
                                "required" = [
                                  "diskName",
                                  "diskURI",
                                ]
                                "type" = "object"
                              }
                              "azureFile" = {
                                "description" = <<-EOT
                                azureFile represents an Azure File Service mount on the host and bind mount to the pod.
                                Deprecated: AzureFile is deprecated. All operations for the in-tree azureFile type
                                are redirected to the file.csi.azure.com CSI driver.
                                EOT
                                "properties" = {
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "secretName" = {
                                    "description" = "secretName is the  name of secret that contains Azure Storage Account Name and Key"
                                    "type"        = "string"
                                  }
                                  "shareName" = {
                                    "description" = "shareName is the azure share Name"
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "secretName",
                                  "shareName",
                                ]
                                "type" = "object"
                              }
                              "cephfs" = {
                                "description" = <<-EOT
                                cephFS represents a Ceph FS mount on the host that shares a pod's lifetime.
                                Deprecated: CephFS is deprecated and the in-tree cephfs type is no longer supported.
                                EOT
                                "properties" = {
                                  "monitors" = {
                                    "description" = <<-EOT
                                    monitors is Required: Monitors is a collection of Ceph monitors
                                    More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
                                    EOT
                                    "items" = {
                                      "type" = "string"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                  "path" = {
                                    "description" = "path is Optional: Used as the mounted root, rather than the full Ceph tree, default is /"
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly is Optional: Defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "secretFile" = {
                                    "description" = <<-EOT
                                    secretFile is Optional: SecretFile is the path to key ring for User, default is /etc/ceph/user.secret
                                    More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
                                    EOT
                                    "type"        = "string"
                                  }
                                  "secretRef" = {
                                    "description" = <<-EOT
                                    secretRef is Optional: SecretRef is reference to the authentication secret for User, default is empty.
                                    More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
                                    EOT
                                    "properties" = {
                                      "name" = {
                                        "default"     = ""
                                        "description" = <<-EOT
                                        Name of the referent.
                                        This field is effectively required, but due to backwards compatibility is
                                        allowed to be empty. Instances of this type with an empty value here are
                                        almost certainly wrong.
                                        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                        EOT
                                        "type"        = "string"
                                      }
                                    }
                                    "type"                  = "object"
                                    "x-kubernetes-map-type" = "atomic"
                                  }
                                  "user" = {
                                    "description" = <<-EOT
                                    user is optional: User is the rados user name, default is admin
                                    More info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "monitors",
                                ]
                                "type" = "object"
                              }
                              "cinder" = {
                                "description" = <<-EOT
                                cinder represents a cinder volume attached and mounted on kubelets host machine.
                                Deprecated: Cinder is deprecated. All operations for the in-tree cinder type
                                are redirected to the cinder.csi.openstack.org CSI driver.
                                More info: https://examples.k8s.io/mysql-cinder-pd/README.md
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is the filesystem type to mount.
                                    Must be a filesystem type supported by the host operating system.
                                    Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    More info: https://examples.k8s.io/mysql-cinder-pd/README.md
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    More info: https://examples.k8s.io/mysql-cinder-pd/README.md
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "secretRef" = {
                                    "description" = <<-EOT
                                    secretRef is optional: points to a secret object containing parameters used to connect
                                    to OpenStack.
                                    EOT
                                    "properties" = {
                                      "name" = {
                                        "default"     = ""
                                        "description" = <<-EOT
                                        Name of the referent.
                                        This field is effectively required, but due to backwards compatibility is
                                        allowed to be empty. Instances of this type with an empty value here are
                                        almost certainly wrong.
                                        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                        EOT
                                        "type"        = "string"
                                      }
                                    }
                                    "type"                  = "object"
                                    "x-kubernetes-map-type" = "atomic"
                                  }
                                  "volumeID" = {
                                    "description" = <<-EOT
                                    volumeID used to identify the volume in cinder.
                                    More info: https://examples.k8s.io/mysql-cinder-pd/README.md
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "volumeID",
                                ]
                                "type" = "object"
                              }
                              "configMap" = {
                                "description" = "configMap represents a configMap that should populate this volume"
                                "properties" = {
                                  "defaultMode" = {
                                    "description" = <<-EOT
                                    defaultMode is optional: mode bits used to set permissions on created files by default.
                                    Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
                                    YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                    Defaults to 0644.
                                    Directories within the path are not affected by this setting.
                                    This might be in conflict with other options that affect the file
                                    mode, like fsGroup, and the result can be other mode bits set.
                                    EOT
                                    "format"      = "int32"
                                    "type"        = "integer"
                                  }
                                  "items" = {
                                    "description" = <<-EOT
                                    items if unspecified, each key-value pair in the Data field of the referenced
                                    ConfigMap will be projected into the volume as a file whose name is the
                                    key and content is the value. If specified, the listed keys will be
                                    projected into the specified paths, and unlisted keys will not be
                                    present. If a key is specified which is not present in the ConfigMap,
                                    the volume setup will error unless it is marked optional. Paths must be
                                    relative and may not contain the '..' path or start with '..'.
                                    EOT
                                    "items" = {
                                      "description" = "Maps a string key to a path within a volume."
                                      "properties" = {
                                        "key" = {
                                          "description" = "key is the key to project."
                                          "type"        = "string"
                                        }
                                        "mode" = {
                                          "description" = <<-EOT
                                          mode is Optional: mode bits used to set permissions on this file.
                                          Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
                                          YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                          If not specified, the volume defaultMode will be used.
                                          This might be in conflict with other options that affect the file
                                          mode, like fsGroup, and the result can be other mode bits set.
                                          EOT
                                          "format"      = "int32"
                                          "type"        = "integer"
                                        }
                                        "path" = {
                                          "description" = <<-EOT
                                          path is the relative path of the file to map the key to.
                                          May not be an absolute path.
                                          May not contain the path element '..'.
                                          May not start with the string '..'.
                                          EOT
                                          "type"        = "string"
                                        }
                                      }
                                      "required" = [
                                        "key",
                                        "path",
                                      ]
                                      "type" = "object"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                  "name" = {
                                    "default"     = ""
                                    "description" = <<-EOT
                                    Name of the referent.
                                    This field is effectively required, but due to backwards compatibility is
                                    allowed to be empty. Instances of this type with an empty value here are
                                    almost certainly wrong.
                                    More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                    EOT
                                    "type"        = "string"
                                  }
                                  "optional" = {
                                    "description" = "optional specify whether the ConfigMap or its keys must be defined"
                                    "type"        = "boolean"
                                  }
                                }
                                "type"                  = "object"
                                "x-kubernetes-map-type" = "atomic"
                              }
                              "csi" = {
                                "description" = "csi (Container Storage Interface) represents ephemeral storage that is handled by certain external CSI drivers."
                                "properties" = {
                                  "driver" = {
                                    "description" = <<-EOT
                                    driver is the name of the CSI driver that handles this volume.
                                    Consult with your admin for the correct name as registered in the cluster.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType to mount. Ex. "ext4", "xfs", "ntfs".
                                    If not provided, the empty value is passed to the associated CSI driver
                                    which will determine the default filesystem to apply.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "nodePublishSecretRef" = {
                                    "description" = <<-EOT
                                    nodePublishSecretRef is a reference to the secret object containing
                                    sensitive information to pass to the CSI driver to complete the CSI
                                    NodePublishVolume and NodeUnpublishVolume calls.
                                    This field is optional, and  may be empty if no secret is required. If the
                                    secret object contains more than one secret, all secret references are passed.
                                    EOT
                                    "properties" = {
                                      "name" = {
                                        "default"     = ""
                                        "description" = <<-EOT
                                        Name of the referent.
                                        This field is effectively required, but due to backwards compatibility is
                                        allowed to be empty. Instances of this type with an empty value here are
                                        almost certainly wrong.
                                        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                        EOT
                                        "type"        = "string"
                                      }
                                    }
                                    "type"                  = "object"
                                    "x-kubernetes-map-type" = "atomic"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly specifies a read-only configuration for the volume.
                                    Defaults to false (read/write).
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "volumeAttributes" = {
                                    "additionalProperties" = {
                                      "type" = "string"
                                    }
                                    "description" = <<-EOT
                                    volumeAttributes stores driver-specific properties that are passed to the CSI
                                    driver. Consult your driver's documentation for supported values.
                                    EOT
                                    "type"        = "object"
                                  }
                                }
                                "required" = [
                                  "driver",
                                ]
                                "type" = "object"
                              }
                              "downwardAPI" = {
                                "description" = "downwardAPI represents downward API about the pod that should populate this volume"
                                "properties" = {
                                  "defaultMode" = {
                                    "description" = <<-EOT
                                    Optional: mode bits to use on created files by default. Must be a
                                    Optional: mode bits used to set permissions on created files by default.
                                    Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
                                    YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                    Defaults to 0644.
                                    Directories within the path are not affected by this setting.
                                    This might be in conflict with other options that affect the file
                                    mode, like fsGroup, and the result can be other mode bits set.
                                    EOT
                                    "format"      = "int32"
                                    "type"        = "integer"
                                  }
                                  "items" = {
                                    "description" = "Items is a list of downward API volume file"
                                    "items" = {
                                      "description" = "DownwardAPIVolumeFile represents information to create the file containing the pod field"
                                      "properties" = {
                                        "fieldRef" = {
                                          "description" = "Required: Selects a field of the pod: only annotations, labels, name, namespace and uid are supported."
                                          "properties" = {
                                            "apiVersion" = {
                                              "description" = "Version of the schema the FieldPath is written in terms of, defaults to \"v1\"."
                                              "type"        = "string"
                                            }
                                            "fieldPath" = {
                                              "description" = "Path of the field to select in the specified API version."
                                              "type"        = "string"
                                            }
                                          }
                                          "required" = [
                                            "fieldPath",
                                          ]
                                          "type"                  = "object"
                                          "x-kubernetes-map-type" = "atomic"
                                        }
                                        "mode" = {
                                          "description" = <<-EOT
                                          Optional: mode bits used to set permissions on this file, must be an octal value
                                          between 0000 and 0777 or a decimal value between 0 and 511.
                                          YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                          If not specified, the volume defaultMode will be used.
                                          This might be in conflict with other options that affect the file
                                          mode, like fsGroup, and the result can be other mode bits set.
                                          EOT
                                          "format"      = "int32"
                                          "type"        = "integer"
                                        }
                                        "path" = {
                                          "description" = "Required: Path is  the relative path name of the file to be created. Must not be absolute or contain the '..' path. Must be utf-8 encoded. The first item of the relative path must not start with '..'"
                                          "type"        = "string"
                                        }
                                        "resourceFieldRef" = {
                                          "description" = <<-EOT
                                          Selects a resource of the container: only resources limits and requests
                                          (limits.cpu, limits.memory, requests.cpu and requests.memory) are currently supported.
                                          EOT
                                          "properties" = {
                                            "containerName" = {
                                              "description" = "Container name: required for volumes, optional for env vars"
                                              "type"        = "string"
                                            }
                                            "divisor" = {
                                              "anyOf" = [
                                                {
                                                  "type" = "integer"
                                                },
                                                {
                                                  "type" = "string"
                                                },
                                              ]
                                              "description"                = "Specifies the output format of the exposed resources, defaults to \"1\""
                                              "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                              "x-kubernetes-int-or-string" = true
                                            }
                                            "resource" = {
                                              "description" = "Required: resource to select"
                                              "type"        = "string"
                                            }
                                          }
                                          "required" = [
                                            "resource",
                                          ]
                                          "type"                  = "object"
                                          "x-kubernetes-map-type" = "atomic"
                                        }
                                      }
                                      "required" = [
                                        "path",
                                      ]
                                      "type" = "object"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                }
                                "type" = "object"
                              }
                              "emptyDir" = {
                                "description" = <<-EOT
                                emptyDir represents a temporary directory that shares a pod's lifetime.
                                More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir
                                EOT
                                "properties" = {
                                  "medium" = {
                                    "description" = <<-EOT
                                    medium represents what type of storage medium should back this directory.
                                    The default is "" which means to use the node's default medium.
                                    Must be an empty string (default) or Memory.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir
                                    EOT
                                    "type"        = "string"
                                  }
                                  "sizeLimit" = {
                                    "anyOf" = [
                                      {
                                        "type" = "integer"
                                      },
                                      {
                                        "type" = "string"
                                      },
                                    ]
                                    "description"                = <<-EOT
                                    sizeLimit is the total amount of local storage required for this EmptyDir volume.
                                    The size limit is also applicable for memory medium.
                                    The maximum usage on memory medium EmptyDir would be the minimum value between
                                    the SizeLimit specified here and the sum of memory limits of all containers in a pod.
                                    The default is nil which means that the limit is undefined.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir
                                    EOT
                                    "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                    "x-kubernetes-int-or-string" = true
                                  }
                                }
                                "type" = "object"
                              }
                              "ephemeral" = {
                                "description" = <<-EOT
                                ephemeral represents a volume that is handled by a cluster storage driver.
                                The volume's lifecycle is tied to the pod that defines it - it will be created before the pod starts,
                                and deleted when the pod is removed.
                                Use this if:
                                a) the volume is only needed while the pod runs,
                                b) features of normal volumes like restoring from snapshot or capacity
                                   tracking are needed,
                                c) the storage driver is specified through a storage class, and
                                d) the storage driver supports dynamic volume provisioning through
                                   a PersistentVolumeClaim (see EphemeralVolumeSource for more
                                   information on the connection between this volume type
                                   and PersistentVolumeClaim).
                                Use PersistentVolumeClaim or one of the vendor-specific
                                APIs for volumes that persist for longer than the lifecycle
                                of an individual pod.
                                Use CSI for light-weight local ephemeral volumes if the CSI driver is meant to
                                be used that way - see the documentation of the driver for
                                more information.
                                A pod can use both types of ephemeral volumes and
                                persistent volumes at the same time.
                                EOT
                                "properties" = {
                                  "volumeClaimTemplate" = {
                                    "description" = <<-EOT
                                    Will be used to create a stand-alone PVC to provision the volume.
                                    The pod in which this EphemeralVolumeSource is embedded will be the
                                    owner of the PVC, i.e. the PVC will be deleted together with the
                                    pod.  The name of the PVC will be `<pod name>-<volume name>` where
                                    `<volume name>` is the name from the `PodSpec.Volumes` array
                                    entry. Pod validation will reject the pod if the concatenated name
                                    is not valid for a PVC (for example, too long).
                                    An existing PVC with that name that is not owned by the pod
                                    will *not* be used for the pod to avoid using an unrelated
                                    volume by mistake. Starting the pod is then blocked until
                                    the unrelated PVC is removed. If such a pre-created PVC is
                                    meant to be used by the pod, the PVC has to updated with an
                                    owner reference to the pod once the pod exists. Normally
                                    this should not be necessary, but it may be useful when
                                    manually reconstructing a broken cluster.
                                    This field is read-only and no changes will be made by Kubernetes
                                    to the PVC after it has been created.
                                    Required, must not be nil.
                                    EOT
                                    "properties" = {
                                      "metadata" = {
                                        "description" = <<-EOT
                                        May contain labels and annotations that will be copied into the PVC
                                        when creating it. No other fields are allowed and will be rejected during
                                        validation.
                                        EOT
                                        "type"        = "object"
                                      }
                                      "spec" = {
                                        "description" = <<-EOT
                                        The specification for the PersistentVolumeClaim. The entire content is
                                        copied unchanged into the PVC that gets created from this
                                        template. The same fields as in a PersistentVolumeClaim
                                        are also valid here.
                                        EOT
                                        "properties" = {
                                          "accessModes" = {
                                            "description" = <<-EOT
                                            accessModes contains the desired access modes the volume should have.
                                            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1
                                            EOT
                                            "items" = {
                                              "type" = "string"
                                            }
                                            "type"                   = "array"
                                            "x-kubernetes-list-type" = "atomic"
                                          }
                                          "dataSource" = {
                                            "description" = <<-EOT
                                            dataSource field can be used to specify either:
                                            * An existing VolumeSnapshot object (snapshot.storage.k8s.io/VolumeSnapshot)
                                            * An existing PVC (PersistentVolumeClaim)
                                            If the provisioner or an external controller can support the specified data source,
                                            it will create a new volume based on the contents of the specified data source.
                                            When the AnyVolumeDataSource feature gate is enabled, dataSource contents will be copied to dataSourceRef,
                                            and dataSourceRef contents will be copied to dataSource when dataSourceRef.namespace is not specified.
                                            If the namespace is specified, then dataSourceRef will not be copied to dataSource.
                                            EOT
                                            "properties" = {
                                              "apiGroup" = {
                                                "description" = <<-EOT
                                                APIGroup is the group for the resource being referenced.
                                                If APIGroup is not specified, the specified Kind must be in the core API group.
                                                For any other third-party types, APIGroup is required.
                                                EOT
                                                "type"        = "string"
                                              }
                                              "kind" = {
                                                "description" = "Kind is the type of resource being referenced"
                                                "type"        = "string"
                                              }
                                              "name" = {
                                                "description" = "Name is the name of resource being referenced"
                                                "type"        = "string"
                                              }
                                            }
                                            "required" = [
                                              "kind",
                                              "name",
                                            ]
                                            "type"                  = "object"
                                            "x-kubernetes-map-type" = "atomic"
                                          }
                                          "dataSourceRef" = {
                                            "description" = <<-EOT
                                            dataSourceRef specifies the object from which to populate the volume with data, if a non-empty
                                            volume is desired. This may be any object from a non-empty API group (non
                                            core object) or a PersistentVolumeClaim object.
                                            When this field is specified, volume binding will only succeed if the type of
                                            the specified object matches some installed volume populator or dynamic
                                            provisioner.
                                            This field will replace the functionality of the dataSource field and as such
                                            if both fields are non-empty, they must have the same value. For backwards
                                            compatibility, when namespace isn't specified in dataSourceRef,
                                            both fields (dataSource and dataSourceRef) will be set to the same
                                            value automatically if one of them is empty and the other is non-empty.
                                            When namespace is specified in dataSourceRef,
                                            dataSource isn't set to the same value and must be empty.
                                            There are three important differences between dataSource and dataSourceRef:
                                            * While dataSource only allows two specific types of objects, dataSourceRef
                                              allows any non-core object, as well as PersistentVolumeClaim objects.
                                            * While dataSource ignores disallowed values (dropping them), dataSourceRef
                                              preserves all values, and generates an error if a disallowed value is
                                              specified.
                                            * While dataSource only allows local objects, dataSourceRef allows objects
                                              in any namespaces.
                                            (Beta) Using this field requires the AnyVolumeDataSource feature gate to be enabled.
                                            (Alpha) Using the namespace field of dataSourceRef requires the CrossNamespaceVolumeDataSource feature gate to be enabled.
                                            EOT
                                            "properties" = {
                                              "apiGroup" = {
                                                "description" = <<-EOT
                                                APIGroup is the group for the resource being referenced.
                                                If APIGroup is not specified, the specified Kind must be in the core API group.
                                                For any other third-party types, APIGroup is required.
                                                EOT
                                                "type"        = "string"
                                              }
                                              "kind" = {
                                                "description" = "Kind is the type of resource being referenced"
                                                "type"        = "string"
                                              }
                                              "name" = {
                                                "description" = "Name is the name of resource being referenced"
                                                "type"        = "string"
                                              }
                                              "namespace" = {
                                                "description" = <<-EOT
                                                Namespace is the namespace of resource being referenced
                                                Note that when a namespace is specified, a gateway.networking.k8s.io/ReferenceGrant object is required in the referent namespace to allow that namespace's owner to accept the reference. See the ReferenceGrant documentation for details.
                                                (Alpha) This field requires the CrossNamespaceVolumeDataSource feature gate to be enabled.
                                                EOT
                                                "type"        = "string"
                                              }
                                            }
                                            "required" = [
                                              "kind",
                                              "name",
                                            ]
                                            "type" = "object"
                                          }
                                          "resources" = {
                                            "description" = <<-EOT
                                            resources represents the minimum resources the volume should have.
                                            If RecoverVolumeExpansionFailure feature is enabled users are allowed to specify resource requirements
                                            that are lower than previous value but must still be higher than capacity recorded in the
                                            status field of the claim.
                                            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources
                                            EOT
                                            "properties" = {
                                              "limits" = {
                                                "additionalProperties" = {
                                                  "anyOf" = [
                                                    {
                                                      "type" = "integer"
                                                    },
                                                    {
                                                      "type" = "string"
                                                    },
                                                  ]
                                                  "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                                  "x-kubernetes-int-or-string" = true
                                                }
                                                "description" = <<-EOT
                                                Limits describes the maximum amount of compute resources allowed.
                                                More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                                                EOT
                                                "type"        = "object"
                                              }
                                              "requests" = {
                                                "additionalProperties" = {
                                                  "anyOf" = [
                                                    {
                                                      "type" = "integer"
                                                    },
                                                    {
                                                      "type" = "string"
                                                    },
                                                  ]
                                                  "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                                  "x-kubernetes-int-or-string" = true
                                                }
                                                "description" = <<-EOT
                                                Requests describes the minimum amount of compute resources required.
                                                If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
                                                otherwise to an implementation-defined value. Requests cannot exceed Limits.
                                                More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                                                EOT
                                                "type"        = "object"
                                              }
                                            }
                                            "type" = "object"
                                          }
                                          "selector" = {
                                            "description" = "selector is a label query over volumes to consider for binding."
                                            "properties" = {
                                              "matchExpressions" = {
                                                "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                                                "items" = {
                                                  "description" = <<-EOT
                                                  A label selector requirement is a selector that contains values, a key, and an operator that
                                                  relates the key and values.
                                                  EOT
                                                  "properties" = {
                                                    "key" = {
                                                      "description" = "key is the label key that the selector applies to."
                                                      "type"        = "string"
                                                    }
                                                    "operator" = {
                                                      "description" = <<-EOT
                                                      operator represents a key's relationship to a set of values.
                                                      Valid operators are In, NotIn, Exists and DoesNotExist.
                                                      EOT
                                                      "type"        = "string"
                                                    }
                                                    "values" = {
                                                      "description" = <<-EOT
                                                      values is an array of string values. If the operator is In or NotIn,
                                                      the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                                      the values array must be empty. This array is replaced during a strategic
                                                      merge patch.
                                                      EOT
                                                      "items" = {
                                                        "type" = "string"
                                                      }
                                                      "type"                   = "array"
                                                      "x-kubernetes-list-type" = "atomic"
                                                    }
                                                  }
                                                  "required" = [
                                                    "key",
                                                    "operator",
                                                  ]
                                                  "type" = "object"
                                                }
                                                "type"                   = "array"
                                                "x-kubernetes-list-type" = "atomic"
                                              }
                                              "matchLabels" = {
                                                "additionalProperties" = {
                                                  "type" = "string"
                                                }
                                                "description" = <<-EOT
                                                matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                                                map is equivalent to an element of matchExpressions, whose key field is "key", the
                                                operator is "In", and the values array contains only "value". The requirements are ANDed.
                                                EOT
                                                "type"        = "object"
                                              }
                                            }
                                            "type"                  = "object"
                                            "x-kubernetes-map-type" = "atomic"
                                          }
                                          "storageClassName" = {
                                            "description" = <<-EOT
                                            storageClassName is the name of the StorageClass required by the claim.
                                            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1
                                            EOT
                                            "type"        = "string"
                                          }
                                          "volumeAttributesClassName" = {
                                            "description" = <<-EOT
                                            volumeAttributesClassName may be used to set the VolumeAttributesClass used by this claim.
                                            If specified, the CSI driver will create or update the volume with the attributes defined
                                            in the corresponding VolumeAttributesClass. This has a different purpose than storageClassName,
                                            it can be changed after the claim is created. An empty string value means that no VolumeAttributesClass
                                            will be applied to the claim but it's not allowed to reset this field to empty string once it is set.
                                            If unspecified and the PersistentVolumeClaim is unbound, the default VolumeAttributesClass
                                            will be set by the persistentvolume controller if it exists.
                                            If the resource referred to by volumeAttributesClass does not exist, this PersistentVolumeClaim will be
                                            set to a Pending state, as reflected by the modifyVolumeStatus field, until such as a resource
                                            exists.
                                            More info: https://kubernetes.io/docs/concepts/storage/volume-attributes-classes/
                                            (Beta) Using this field requires the VolumeAttributesClass feature gate to be enabled (off by default).
                                            EOT
                                            "type"        = "string"
                                          }
                                          "volumeMode" = {
                                            "description" = <<-EOT
                                            volumeMode defines what type of volume is required by the claim.
                                            Value of Filesystem is implied when not included in claim spec.
                                            EOT
                                            "type"        = "string"
                                          }
                                          "volumeName" = {
                                            "description" = "volumeName is the binding reference to the PersistentVolume backing this claim."
                                            "type"        = "string"
                                          }
                                        }
                                        "type" = "object"
                                      }
                                    }
                                    "required" = [
                                      "spec",
                                    ]
                                    "type" = "object"
                                  }
                                }
                                "type" = "object"
                              }
                              "fc" = {
                                "description" = "fc represents a Fibre Channel resource that is attached to a kubelet's host machine and then exposed to the pod."
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is the filesystem type to mount.
                                    Must be a filesystem type supported by the host operating system.
                                    Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "lun" = {
                                    "description" = "lun is Optional: FC target lun number"
                                    "format"      = "int32"
                                    "type"        = "integer"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly is Optional: Defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "targetWWNs" = {
                                    "description" = "targetWWNs is Optional: FC target worldwide names (WWNs)"
                                    "items" = {
                                      "type" = "string"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                  "wwids" = {
                                    "description" = <<-EOT
                                    wwids Optional: FC volume world wide identifiers (wwids)
                                    Either wwids or combination of targetWWNs and lun must be set, but not both simultaneously.
                                    EOT
                                    "items" = {
                                      "type" = "string"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                }
                                "type" = "object"
                              }
                              "flexVolume" = {
                                "description" = <<-EOT
                                flexVolume represents a generic volume resource that is
                                provisioned/attached using an exec based plugin.
                                Deprecated: FlexVolume is deprecated. Consider using a CSIDriver instead.
                                EOT
                                "properties" = {
                                  "driver" = {
                                    "description" = "driver is the name of the driver to use for this volume."
                                    "type"        = "string"
                                  }
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is the filesystem type to mount.
                                    Must be a filesystem type supported by the host operating system.
                                    Ex. "ext4", "xfs", "ntfs". The default filesystem depends on FlexVolume script.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "options" = {
                                    "additionalProperties" = {
                                      "type" = "string"
                                    }
                                    "description" = "options is Optional: this field holds extra command options if any."
                                    "type"        = "object"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly is Optional: defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "secretRef" = {
                                    "description" = <<-EOT
                                    secretRef is Optional: secretRef is reference to the secret object containing
                                    sensitive information to pass to the plugin scripts. This may be
                                    empty if no secret object is specified. If the secret object
                                    contains more than one secret, all secrets are passed to the plugin
                                    scripts.
                                    EOT
                                    "properties" = {
                                      "name" = {
                                        "default"     = ""
                                        "description" = <<-EOT
                                        Name of the referent.
                                        This field is effectively required, but due to backwards compatibility is
                                        allowed to be empty. Instances of this type with an empty value here are
                                        almost certainly wrong.
                                        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                        EOT
                                        "type"        = "string"
                                      }
                                    }
                                    "type"                  = "object"
                                    "x-kubernetes-map-type" = "atomic"
                                  }
                                }
                                "required" = [
                                  "driver",
                                ]
                                "type" = "object"
                              }
                              "flocker" = {
                                "description" = <<-EOT
                                flocker represents a Flocker volume attached to a kubelet's host machine. This depends on the Flocker control service being running.
                                Deprecated: Flocker is deprecated and the in-tree flocker type is no longer supported.
                                EOT
                                "properties" = {
                                  "datasetName" = {
                                    "description" = <<-EOT
                                    datasetName is Name of the dataset stored as metadata -> name on the dataset for Flocker
                                    should be considered as deprecated
                                    EOT
                                    "type"        = "string"
                                  }
                                  "datasetUUID" = {
                                    "description" = "datasetUUID is the UUID of the dataset. This is unique identifier of a Flocker dataset"
                                    "type"        = "string"
                                  }
                                }
                                "type" = "object"
                              }
                              "gcePersistentDisk" = {
                                "description" = <<-EOT
                                gcePersistentDisk represents a GCE Disk resource that is attached to a
                                kubelet's host machine and then exposed to the pod.
                                Deprecated: GCEPersistentDisk is deprecated. All operations for the in-tree
                                gcePersistentDisk type are redirected to the pd.csi.storage.gke.io CSI driver.
                                More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is filesystem type of the volume that you want to mount.
                                    Tip: Ensure that the filesystem type is supported by the host operating system.
                                    Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
                                    EOT
                                    "type"        = "string"
                                  }
                                  "partition" = {
                                    "description" = <<-EOT
                                    partition is the partition in the volume that you want to mount.
                                    If omitted, the default is to mount by volume name.
                                    Examples: For volume /dev/sda1, you specify the partition as "1".
                                    Similarly, the volume partition for /dev/sda is "0" (or you can leave the property empty).
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
                                    EOT
                                    "format"      = "int32"
                                    "type"        = "integer"
                                  }
                                  "pdName" = {
                                    "description" = <<-EOT
                                    pdName is unique name of the PD resource in GCE. Used to identify the disk in GCE.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly here will force the ReadOnly setting in VolumeMounts.
                                    Defaults to false.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk
                                    EOT
                                    "type"        = "boolean"
                                  }
                                }
                                "required" = [
                                  "pdName",
                                ]
                                "type" = "object"
                              }
                              "gitRepo" = {
                                "description" = <<-EOT
                                gitRepo represents a git repository at a particular revision.
                                Deprecated: GitRepo is deprecated. To provision a container with a git repo, mount an
                                EmptyDir into an InitContainer that clones the repo using git, then mount the EmptyDir
                                into the Pod's container.
                                EOT
                                "properties" = {
                                  "directory" = {
                                    "description" = <<-EOT
                                    directory is the target directory name.
                                    Must not contain or start with '..'.  If '.' is supplied, the volume directory will be the
                                    git repository.  Otherwise, if specified, the volume will contain the git repository in
                                    the subdirectory with the given name.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "repository" = {
                                    "description" = "repository is the URL"
                                    "type"        = "string"
                                  }
                                  "revision" = {
                                    "description" = "revision is the commit hash for the specified revision."
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "repository",
                                ]
                                "type" = "object"
                              }
                              "glusterfs" = {
                                "description" = <<-EOT
                                glusterfs represents a Glusterfs mount on the host that shares a pod's lifetime.
                                Deprecated: Glusterfs is deprecated and the in-tree glusterfs type is no longer supported.
                                More info: https://examples.k8s.io/volumes/glusterfs/README.md
                                EOT
                                "properties" = {
                                  "endpoints" = {
                                    "description" = <<-EOT
                                    endpoints is the endpoint name that details Glusterfs topology.
                                    More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
                                    EOT
                                    "type"        = "string"
                                  }
                                  "path" = {
                                    "description" = <<-EOT
                                    path is the Glusterfs volume path.
                                    More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly here will force the Glusterfs volume to be mounted with read-only permissions.
                                    Defaults to false.
                                    More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod
                                    EOT
                                    "type"        = "boolean"
                                  }
                                }
                                "required" = [
                                  "endpoints",
                                  "path",
                                ]
                                "type" = "object"
                              }
                              "hostPath" = {
                                "description" = <<-EOT
                                hostPath represents a pre-existing file or directory on the host
                                machine that is directly exposed to the container. This is generally
                                used for system agents or other privileged things that are allowed
                                to see the host machine. Most containers will NOT need this.
                                More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
                                EOT
                                "properties" = {
                                  "path" = {
                                    "description" = <<-EOT
                                    path of the directory on the host.
                                    If the path is a symlink, it will follow the link to the real path.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
                                    EOT
                                    "type"        = "string"
                                  }
                                  "type" = {
                                    "description" = <<-EOT
                                    type for HostPath Volume
                                    Defaults to ""
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "path",
                                ]
                                "type" = "object"
                              }
                              "image" = {
                                "description" = <<-EOT
                                image represents an OCI object (a container image or artifact) pulled and mounted on the kubelet's host machine.
                                The volume is resolved at pod startup depending on which PullPolicy value is provided:
                                - Always: the kubelet always attempts to pull the reference. Container creation will fail If the pull fails.
                                - Never: the kubelet never pulls the reference and only uses a local image or artifact. Container creation will fail if the reference isn't present.
                                - IfNotPresent: the kubelet pulls if the reference isn't already present on disk. Container creation will fail if the reference isn't present and the pull fails.
                                The volume gets re-resolved if the pod gets deleted and recreated, which means that new remote content will become available on pod recreation.
                                A failure to resolve or pull the image during pod startup will block containers from starting and may add significant latency. Failures will be retried using normal volume backoff and will be reported on the pod reason and message.
                                The types of objects that may be mounted by this volume are defined by the container runtime implementation on a host machine and at minimum must include all valid types supported by the container image field.
                                The OCI object gets mounted in a single directory (spec.containers[*].volumeMounts.mountPath) by merging the manifest layers in the same way as for container images.
                                The volume will be mounted read-only (ro) and non-executable files (noexec).
                                Sub path mounts for containers are not supported (spec.containers[*].volumeMounts.subpath) before 1.33.
                                The field spec.securityContext.fsGroupChangePolicy has no effect on this volume type.
                                EOT
                                "properties" = {
                                  "pullPolicy" = {
                                    "description" = <<-EOT
                                    Policy for pulling OCI objects. Possible values are:
                                    Always: the kubelet always attempts to pull the reference. Container creation will fail If the pull fails.
                                    Never: the kubelet never pulls the reference and only uses a local image or artifact. Container creation will fail if the reference isn't present.
                                    IfNotPresent: the kubelet pulls if the reference isn't already present on disk. Container creation will fail if the reference isn't present and the pull fails.
                                    Defaults to Always if :latest tag is specified, or IfNotPresent otherwise.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "reference" = {
                                    "description" = <<-EOT
                                    Required: Image or artifact reference to be used.
                                    Behaves in the same way as pod.spec.containers[*].image.
                                    Pull secrets will be assembled in the same way as for the container image by looking up node credentials, SA image pull secrets, and pod spec image pull secrets.
                                    More info: https://kubernetes.io/docs/concepts/containers/images
                                    This field is optional to allow higher level config management to default or override
                                    container images in workload controllers like Deployments and StatefulSets.
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "type" = "object"
                              }
                              "iscsi" = {
                                "description" = <<-EOT
                                iscsi represents an ISCSI Disk resource that is attached to a
                                kubelet's host machine and then exposed to the pod.
                                More info: https://examples.k8s.io/volumes/iscsi/README.md
                                EOT
                                "properties" = {
                                  "chapAuthDiscovery" = {
                                    "description" = "chapAuthDiscovery defines whether support iSCSI Discovery CHAP authentication"
                                    "type"        = "boolean"
                                  }
                                  "chapAuthSession" = {
                                    "description" = "chapAuthSession defines whether support iSCSI Session CHAP authentication"
                                    "type"        = "boolean"
                                  }
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is the filesystem type of the volume that you want to mount.
                                    Tip: Ensure that the filesystem type is supported by the host operating system.
                                    Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#iscsi
                                    EOT
                                    "type"        = "string"
                                  }
                                  "initiatorName" = {
                                    "description" = <<-EOT
                                    initiatorName is the custom iSCSI Initiator Name.
                                    If initiatorName is specified with iscsiInterface simultaneously, new iSCSI interface
                                    <target portal>:<volume name> will be created for the connection.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "iqn" = {
                                    "description" = "iqn is the target iSCSI Qualified Name."
                                    "type"        = "string"
                                  }
                                  "iscsiInterface" = {
                                    "default"     = "default"
                                    "description" = <<-EOT
                                    iscsiInterface is the interface Name that uses an iSCSI transport.
                                    Defaults to 'default' (tcp).
                                    EOT
                                    "type"        = "string"
                                  }
                                  "lun" = {
                                    "description" = "lun represents iSCSI Target Lun number."
                                    "format"      = "int32"
                                    "type"        = "integer"
                                  }
                                  "portals" = {
                                    "description" = <<-EOT
                                    portals is the iSCSI Target Portal List. The portal is either an IP or ip_addr:port if the port
                                    is other than default (typically TCP ports 860 and 3260).
                                    EOT
                                    "items" = {
                                      "type" = "string"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly here will force the ReadOnly setting in VolumeMounts.
                                    Defaults to false.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "secretRef" = {
                                    "description" = "secretRef is the CHAP Secret for iSCSI target and initiator authentication"
                                    "properties" = {
                                      "name" = {
                                        "default"     = ""
                                        "description" = <<-EOT
                                        Name of the referent.
                                        This field is effectively required, but due to backwards compatibility is
                                        allowed to be empty. Instances of this type with an empty value here are
                                        almost certainly wrong.
                                        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                        EOT
                                        "type"        = "string"
                                      }
                                    }
                                    "type"                  = "object"
                                    "x-kubernetes-map-type" = "atomic"
                                  }
                                  "targetPortal" = {
                                    "description" = <<-EOT
                                    targetPortal is iSCSI Target Portal. The Portal is either an IP or ip_addr:port if the port
                                    is other than default (typically TCP ports 860 and 3260).
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "iqn",
                                  "lun",
                                  "targetPortal",
                                ]
                                "type" = "object"
                              }
                              "name" = {
                                "description" = <<-EOT
                                name of the volume.
                                Must be a DNS_LABEL and unique within the pod.
                                More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                EOT
                                "type"        = "string"
                              }
                              "nfs" = {
                                "description" = <<-EOT
                                nfs represents an NFS mount on the host that shares a pod's lifetime
                                More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
                                EOT
                                "properties" = {
                                  "path" = {
                                    "description" = <<-EOT
                                    path that is exported by the NFS server.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly here will force the NFS export to be mounted with read-only permissions.
                                    Defaults to false.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "server" = {
                                    "description" = <<-EOT
                                    server is the hostname or IP address of the NFS server.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "path",
                                  "server",
                                ]
                                "type" = "object"
                              }
                              "persistentVolumeClaim" = {
                                "description" = <<-EOT
                                persistentVolumeClaimVolumeSource represents a reference to a
                                PersistentVolumeClaim in the same namespace.
                                More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
                                EOT
                                "properties" = {
                                  "claimName" = {
                                    "description" = <<-EOT
                                    claimName is the name of a PersistentVolumeClaim in the same namespace as the pod using this volume.
                                    More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly Will force the ReadOnly setting in VolumeMounts.
                                    Default false.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                }
                                "required" = [
                                  "claimName",
                                ]
                                "type" = "object"
                              }
                              "photonPersistentDisk" = {
                                "description" = <<-EOT
                                photonPersistentDisk represents a PhotonController persistent disk attached and mounted on kubelets host machine.
                                Deprecated: PhotonPersistentDisk is deprecated and the in-tree photonPersistentDisk type is no longer supported.
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is the filesystem type to mount.
                                    Must be a filesystem type supported by the host operating system.
                                    Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "pdID" = {
                                    "description" = "pdID is the ID that identifies Photon Controller persistent disk"
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "pdID",
                                ]
                                "type" = "object"
                              }
                              "portworxVolume" = {
                                "description" = <<-EOT
                                portworxVolume represents a portworx volume attached and mounted on kubelets host machine.
                                Deprecated: PortworxVolume is deprecated. All operations for the in-tree portworxVolume type
                                are redirected to the pxd.portworx.com CSI driver when the CSIMigrationPortworx feature-gate
                                is on.
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fSType represents the filesystem type to mount
                                    Must be a filesystem type supported by the host operating system.
                                    Ex. "ext4", "xfs". Implicitly inferred to be "ext4" if unspecified.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "volumeID" = {
                                    "description" = "volumeID uniquely identifies a Portworx volume"
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "volumeID",
                                ]
                                "type" = "object"
                              }
                              "projected" = {
                                "description" = "projected items for all in one resources secrets, configmaps, and downward API"
                                "properties" = {
                                  "defaultMode" = {
                                    "description" = <<-EOT
                                    defaultMode are the mode bits used to set permissions on created files by default.
                                    Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
                                    YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                    Directories within the path are not affected by this setting.
                                    This might be in conflict with other options that affect the file
                                    mode, like fsGroup, and the result can be other mode bits set.
                                    EOT
                                    "format"      = "int32"
                                    "type"        = "integer"
                                  }
                                  "sources" = {
                                    "description" = <<-EOT
                                    sources is the list of volume projections. Each entry in this list
                                    handles one source.
                                    EOT
                                    "items" = {
                                      "description" = <<-EOT
                                      Projection that may be projected along with other supported volume types.
                                      Exactly one of these fields must be set.
                                      EOT
                                      "properties" = {
                                        "clusterTrustBundle" = {
                                          "description" = <<-EOT
                                          ClusterTrustBundle allows a pod to access the `.spec.trustBundle` field
                                          of ClusterTrustBundle objects in an auto-updating file.
                                          Alpha, gated by the ClusterTrustBundleProjection feature gate.
                                          ClusterTrustBundle objects can either be selected by name, or by the
                                          combination of signer name and a label selector.
                                          Kubelet performs aggressive normalization of the PEM contents written
                                          into the pod filesystem.  Esoteric PEM features such as inter-block
                                          comments and block headers are stripped.  Certificates are deduplicated.
                                          The ordering of certificates within the file is arbitrary, and Kubelet
                                          may change the order over time.
                                          EOT
                                          "properties" = {
                                            "labelSelector" = {
                                              "description" = <<-EOT
                                              Select all ClusterTrustBundles that match this label selector.  Only has
                                              effect if signerName is set.  Mutually-exclusive with name.  If unset,
                                              interpreted as "match nothing".  If set but empty, interpreted as "match
                                              everything".
                                              EOT
                                              "properties" = {
                                                "matchExpressions" = {
                                                  "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                                                  "items" = {
                                                    "description" = <<-EOT
                                                    A label selector requirement is a selector that contains values, a key, and an operator that
                                                    relates the key and values.
                                                    EOT
                                                    "properties" = {
                                                      "key" = {
                                                        "description" = "key is the label key that the selector applies to."
                                                        "type"        = "string"
                                                      }
                                                      "operator" = {
                                                        "description" = <<-EOT
                                                        operator represents a key's relationship to a set of values.
                                                        Valid operators are In, NotIn, Exists and DoesNotExist.
                                                        EOT
                                                        "type"        = "string"
                                                      }
                                                      "values" = {
                                                        "description" = <<-EOT
                                                        values is an array of string values. If the operator is In or NotIn,
                                                        the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                                        the values array must be empty. This array is replaced during a strategic
                                                        merge patch.
                                                        EOT
                                                        "items" = {
                                                          "type" = "string"
                                                        }
                                                        "type"                   = "array"
                                                        "x-kubernetes-list-type" = "atomic"
                                                      }
                                                    }
                                                    "required" = [
                                                      "key",
                                                      "operator",
                                                    ]
                                                    "type" = "object"
                                                  }
                                                  "type"                   = "array"
                                                  "x-kubernetes-list-type" = "atomic"
                                                }
                                                "matchLabels" = {
                                                  "additionalProperties" = {
                                                    "type" = "string"
                                                  }
                                                  "description" = <<-EOT
                                                  matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                                                  map is equivalent to an element of matchExpressions, whose key field is "key", the
                                                  operator is "In", and the values array contains only "value". The requirements are ANDed.
                                                  EOT
                                                  "type"        = "object"
                                                }
                                              }
                                              "type"                  = "object"
                                              "x-kubernetes-map-type" = "atomic"
                                            }
                                            "name" = {
                                              "description" = <<-EOT
                                              Select a single ClusterTrustBundle by object name.  Mutually-exclusive
                                              with signerName and labelSelector.
                                              EOT
                                              "type"        = "string"
                                            }
                                            "optional" = {
                                              "description" = <<-EOT
                                              If true, don't block pod startup if the referenced ClusterTrustBundle(s)
                                              aren't available.  If using name, then the named ClusterTrustBundle is
                                              allowed not to exist.  If using signerName, then the combination of
                                              signerName and labelSelector is allowed to match zero
                                              ClusterTrustBundles.
                                              EOT
                                              "type"        = "boolean"
                                            }
                                            "path" = {
                                              "description" = "Relative path from the volume root to write the bundle."
                                              "type"        = "string"
                                            }
                                            "signerName" = {
                                              "description" = <<-EOT
                                              Select all ClusterTrustBundles that match this signer name.
                                              Mutually-exclusive with name.  The contents of all selected
                                              ClusterTrustBundles will be unified and deduplicated.
                                              EOT
                                              "type"        = "string"
                                            }
                                          }
                                          "required" = [
                                            "path",
                                          ]
                                          "type" = "object"
                                        }
                                        "configMap" = {
                                          "description" = "configMap information about the configMap data to project"
                                          "properties" = {
                                            "items" = {
                                              "description" = <<-EOT
                                              items if unspecified, each key-value pair in the Data field of the referenced
                                              ConfigMap will be projected into the volume as a file whose name is the
                                              key and content is the value. If specified, the listed keys will be
                                              projected into the specified paths, and unlisted keys will not be
                                              present. If a key is specified which is not present in the ConfigMap,
                                              the volume setup will error unless it is marked optional. Paths must be
                                              relative and may not contain the '..' path or start with '..'.
                                              EOT
                                              "items" = {
                                                "description" = "Maps a string key to a path within a volume."
                                                "properties" = {
                                                  "key" = {
                                                    "description" = "key is the key to project."
                                                    "type"        = "string"
                                                  }
                                                  "mode" = {
                                                    "description" = <<-EOT
                                                    mode is Optional: mode bits used to set permissions on this file.
                                                    Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
                                                    YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                                    If not specified, the volume defaultMode will be used.
                                                    This might be in conflict with other options that affect the file
                                                    mode, like fsGroup, and the result can be other mode bits set.
                                                    EOT
                                                    "format"      = "int32"
                                                    "type"        = "integer"
                                                  }
                                                  "path" = {
                                                    "description" = <<-EOT
                                                    path is the relative path of the file to map the key to.
                                                    May not be an absolute path.
                                                    May not contain the path element '..'.
                                                    May not start with the string '..'.
                                                    EOT
                                                    "type"        = "string"
                                                  }
                                                }
                                                "required" = [
                                                  "key",
                                                  "path",
                                                ]
                                                "type" = "object"
                                              }
                                              "type"                   = "array"
                                              "x-kubernetes-list-type" = "atomic"
                                            }
                                            "name" = {
                                              "default"     = ""
                                              "description" = <<-EOT
                                              Name of the referent.
                                              This field is effectively required, but due to backwards compatibility is
                                              allowed to be empty. Instances of this type with an empty value here are
                                              almost certainly wrong.
                                              More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              EOT
                                              "type"        = "string"
                                            }
                                            "optional" = {
                                              "description" = "optional specify whether the ConfigMap or its keys must be defined"
                                              "type"        = "boolean"
                                            }
                                          }
                                          "type"                  = "object"
                                          "x-kubernetes-map-type" = "atomic"
                                        }
                                        "downwardAPI" = {
                                          "description" = "downwardAPI information about the downwardAPI data to project"
                                          "properties" = {
                                            "items" = {
                                              "description" = "Items is a list of DownwardAPIVolume file"
                                              "items" = {
                                                "description" = "DownwardAPIVolumeFile represents information to create the file containing the pod field"
                                                "properties" = {
                                                  "fieldRef" = {
                                                    "description" = "Required: Selects a field of the pod: only annotations, labels, name, namespace and uid are supported."
                                                    "properties" = {
                                                      "apiVersion" = {
                                                        "description" = "Version of the schema the FieldPath is written in terms of, defaults to \"v1\"."
                                                        "type"        = "string"
                                                      }
                                                      "fieldPath" = {
                                                        "description" = "Path of the field to select in the specified API version."
                                                        "type"        = "string"
                                                      }
                                                    }
                                                    "required" = [
                                                      "fieldPath",
                                                    ]
                                                    "type"                  = "object"
                                                    "x-kubernetes-map-type" = "atomic"
                                                  }
                                                  "mode" = {
                                                    "description" = <<-EOT
                                                    Optional: mode bits used to set permissions on this file, must be an octal value
                                                    between 0000 and 0777 or a decimal value between 0 and 511.
                                                    YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                                    If not specified, the volume defaultMode will be used.
                                                    This might be in conflict with other options that affect the file
                                                    mode, like fsGroup, and the result can be other mode bits set.
                                                    EOT
                                                    "format"      = "int32"
                                                    "type"        = "integer"
                                                  }
                                                  "path" = {
                                                    "description" = "Required: Path is  the relative path name of the file to be created. Must not be absolute or contain the '..' path. Must be utf-8 encoded. The first item of the relative path must not start with '..'"
                                                    "type"        = "string"
                                                  }
                                                  "resourceFieldRef" = {
                                                    "description" = <<-EOT
                                                    Selects a resource of the container: only resources limits and requests
                                                    (limits.cpu, limits.memory, requests.cpu and requests.memory) are currently supported.
                                                    EOT
                                                    "properties" = {
                                                      "containerName" = {
                                                        "description" = "Container name: required for volumes, optional for env vars"
                                                        "type"        = "string"
                                                      }
                                                      "divisor" = {
                                                        "anyOf" = [
                                                          {
                                                            "type" = "integer"
                                                          },
                                                          {
                                                            "type" = "string"
                                                          },
                                                        ]
                                                        "description"                = "Specifies the output format of the exposed resources, defaults to \"1\""
                                                        "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                                        "x-kubernetes-int-or-string" = true
                                                      }
                                                      "resource" = {
                                                        "description" = "Required: resource to select"
                                                        "type"        = "string"
                                                      }
                                                    }
                                                    "required" = [
                                                      "resource",
                                                    ]
                                                    "type"                  = "object"
                                                    "x-kubernetes-map-type" = "atomic"
                                                  }
                                                }
                                                "required" = [
                                                  "path",
                                                ]
                                                "type" = "object"
                                              }
                                              "type"                   = "array"
                                              "x-kubernetes-list-type" = "atomic"
                                            }
                                          }
                                          "type" = "object"
                                        }
                                        "secret" = {
                                          "description" = "secret information about the secret data to project"
                                          "properties" = {
                                            "items" = {
                                              "description" = <<-EOT
                                              items if unspecified, each key-value pair in the Data field of the referenced
                                              Secret will be projected into the volume as a file whose name is the
                                              key and content is the value. If specified, the listed keys will be
                                              projected into the specified paths, and unlisted keys will not be
                                              present. If a key is specified which is not present in the Secret,
                                              the volume setup will error unless it is marked optional. Paths must be
                                              relative and may not contain the '..' path or start with '..'.
                                              EOT
                                              "items" = {
                                                "description" = "Maps a string key to a path within a volume."
                                                "properties" = {
                                                  "key" = {
                                                    "description" = "key is the key to project."
                                                    "type"        = "string"
                                                  }
                                                  "mode" = {
                                                    "description" = <<-EOT
                                                    mode is Optional: mode bits used to set permissions on this file.
                                                    Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
                                                    YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                                    If not specified, the volume defaultMode will be used.
                                                    This might be in conflict with other options that affect the file
                                                    mode, like fsGroup, and the result can be other mode bits set.
                                                    EOT
                                                    "format"      = "int32"
                                                    "type"        = "integer"
                                                  }
                                                  "path" = {
                                                    "description" = <<-EOT
                                                    path is the relative path of the file to map the key to.
                                                    May not be an absolute path.
                                                    May not contain the path element '..'.
                                                    May not start with the string '..'.
                                                    EOT
                                                    "type"        = "string"
                                                  }
                                                }
                                                "required" = [
                                                  "key",
                                                  "path",
                                                ]
                                                "type" = "object"
                                              }
                                              "type"                   = "array"
                                              "x-kubernetes-list-type" = "atomic"
                                            }
                                            "name" = {
                                              "default"     = ""
                                              "description" = <<-EOT
                                              Name of the referent.
                                              This field is effectively required, but due to backwards compatibility is
                                              allowed to be empty. Instances of this type with an empty value here are
                                              almost certainly wrong.
                                              More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                              EOT
                                              "type"        = "string"
                                            }
                                            "optional" = {
                                              "description" = "optional field specify whether the Secret or its key must be defined"
                                              "type"        = "boolean"
                                            }
                                          }
                                          "type"                  = "object"
                                          "x-kubernetes-map-type" = "atomic"
                                        }
                                        "serviceAccountToken" = {
                                          "description" = "serviceAccountToken is information about the serviceAccountToken data to project"
                                          "properties" = {
                                            "audience" = {
                                              "description" = <<-EOT
                                              audience is the intended audience of the token. A recipient of a token
                                              must identify itself with an identifier specified in the audience of the
                                              token, and otherwise should reject the token. The audience defaults to the
                                              identifier of the apiserver.
                                              EOT
                                              "type"        = "string"
                                            }
                                            "expirationSeconds" = {
                                              "description" = <<-EOT
                                              expirationSeconds is the requested duration of validity of the service
                                              account token. As the token approaches expiration, the kubelet volume
                                              plugin will proactively rotate the service account token. The kubelet will
                                              start trying to rotate the token if the token is older than 80 percent of
                                              its time to live or if the token is older than 24 hours.Defaults to 1 hour
                                              and must be at least 10 minutes.
                                              EOT
                                              "format"      = "int64"
                                              "type"        = "integer"
                                            }
                                            "path" = {
                                              "description" = <<-EOT
                                              path is the path relative to the mount point of the file to project the
                                              token into.
                                              EOT
                                              "type"        = "string"
                                            }
                                          }
                                          "required" = [
                                            "path",
                                          ]
                                          "type" = "object"
                                        }
                                      }
                                      "type" = "object"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                }
                                "type" = "object"
                              }
                              "quobyte" = {
                                "description" = <<-EOT
                                quobyte represents a Quobyte mount on the host that shares a pod's lifetime.
                                Deprecated: Quobyte is deprecated and the in-tree quobyte type is no longer supported.
                                EOT
                                "properties" = {
                                  "group" = {
                                    "description" = <<-EOT
                                    group to map volume access to
                                    Default is no group
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly here will force the Quobyte volume to be mounted with read-only permissions.
                                    Defaults to false.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "registry" = {
                                    "description" = <<-EOT
                                    registry represents a single or multiple Quobyte Registry services
                                    specified as a string as host:port pair (multiple entries are separated with commas)
                                    which acts as the central registry for volumes
                                    EOT
                                    "type"        = "string"
                                  }
                                  "tenant" = {
                                    "description" = <<-EOT
                                    tenant owning the given Quobyte volume in the Backend
                                    Used with dynamically provisioned Quobyte volumes, value is set by the plugin
                                    EOT
                                    "type"        = "string"
                                  }
                                  "user" = {
                                    "description" = <<-EOT
                                    user to map volume access to
                                    Defaults to serivceaccount user
                                    EOT
                                    "type"        = "string"
                                  }
                                  "volume" = {
                                    "description" = "volume is a string that references an already created Quobyte volume by name."
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "registry",
                                  "volume",
                                ]
                                "type" = "object"
                              }
                              "rbd" = {
                                "description" = <<-EOT
                                rbd represents a Rados Block Device mount on the host that shares a pod's lifetime.
                                Deprecated: RBD is deprecated and the in-tree rbd type is no longer supported.
                                More info: https://examples.k8s.io/volumes/rbd/README.md
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is the filesystem type of the volume that you want to mount.
                                    Tip: Ensure that the filesystem type is supported by the host operating system.
                                    Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#rbd
                                    EOT
                                    "type"        = "string"
                                  }
                                  "image" = {
                                    "description" = <<-EOT
                                    image is the rados image name.
                                    More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
                                    EOT
                                    "type"        = "string"
                                  }
                                  "keyring" = {
                                    "default"     = "/etc/ceph/keyring"
                                    "description" = <<-EOT
                                    keyring is the path to key ring for RBDUser.
                                    Default is /etc/ceph/keyring.
                                    More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
                                    EOT
                                    "type"        = "string"
                                  }
                                  "monitors" = {
                                    "description" = <<-EOT
                                    monitors is a collection of Ceph monitors.
                                    More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
                                    EOT
                                    "items" = {
                                      "type" = "string"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                  "pool" = {
                                    "default"     = "rbd"
                                    "description" = <<-EOT
                                    pool is the rados pool name.
                                    Default is rbd.
                                    More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly here will force the ReadOnly setting in VolumeMounts.
                                    Defaults to false.
                                    More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "secretRef" = {
                                    "description" = <<-EOT
                                    secretRef is name of the authentication secret for RBDUser. If provided
                                    overrides keyring.
                                    Default is nil.
                                    More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
                                    EOT
                                    "properties" = {
                                      "name" = {
                                        "default"     = ""
                                        "description" = <<-EOT
                                        Name of the referent.
                                        This field is effectively required, but due to backwards compatibility is
                                        allowed to be empty. Instances of this type with an empty value here are
                                        almost certainly wrong.
                                        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                        EOT
                                        "type"        = "string"
                                      }
                                    }
                                    "type"                  = "object"
                                    "x-kubernetes-map-type" = "atomic"
                                  }
                                  "user" = {
                                    "default"     = "admin"
                                    "description" = <<-EOT
                                    user is the rados user name.
                                    Default is admin.
                                    More info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "image",
                                  "monitors",
                                ]
                                "type" = "object"
                              }
                              "scaleIO" = {
                                "description" = <<-EOT
                                scaleIO represents a ScaleIO persistent volume attached and mounted on Kubernetes nodes.
                                Deprecated: ScaleIO is deprecated and the in-tree scaleIO type is no longer supported.
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "default"     = "xfs"
                                    "description" = <<-EOT
                                    fsType is the filesystem type to mount.
                                    Must be a filesystem type supported by the host operating system.
                                    Ex. "ext4", "xfs", "ntfs".
                                    Default is "xfs".
                                    EOT
                                    "type"        = "string"
                                  }
                                  "gateway" = {
                                    "description" = "gateway is the host address of the ScaleIO API Gateway."
                                    "type"        = "string"
                                  }
                                  "protectionDomain" = {
                                    "description" = "protectionDomain is the name of the ScaleIO Protection Domain for the configured storage."
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly Defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "secretRef" = {
                                    "description" = <<-EOT
                                    secretRef references to the secret for ScaleIO user and other
                                    sensitive information. If this is not provided, Login operation will fail.
                                    EOT
                                    "properties" = {
                                      "name" = {
                                        "default"     = ""
                                        "description" = <<-EOT
                                        Name of the referent.
                                        This field is effectively required, but due to backwards compatibility is
                                        allowed to be empty. Instances of this type with an empty value here are
                                        almost certainly wrong.
                                        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                        EOT
                                        "type"        = "string"
                                      }
                                    }
                                    "type"                  = "object"
                                    "x-kubernetes-map-type" = "atomic"
                                  }
                                  "sslEnabled" = {
                                    "description" = "sslEnabled Flag enable/disable SSL communication with Gateway, default false"
                                    "type"        = "boolean"
                                  }
                                  "storageMode" = {
                                    "default"     = "ThinProvisioned"
                                    "description" = <<-EOT
                                    storageMode indicates whether the storage for a volume should be ThickProvisioned or ThinProvisioned.
                                    Default is ThinProvisioned.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "storagePool" = {
                                    "description" = "storagePool is the ScaleIO Storage Pool associated with the protection domain."
                                    "type"        = "string"
                                  }
                                  "system" = {
                                    "description" = "system is the name of the storage system as configured in ScaleIO."
                                    "type"        = "string"
                                  }
                                  "volumeName" = {
                                    "description" = <<-EOT
                                    volumeName is the name of a volume already created in the ScaleIO system
                                    that is associated with this volume source.
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "gateway",
                                  "secretRef",
                                  "system",
                                ]
                                "type" = "object"
                              }
                              "secret" = {
                                "description" = <<-EOT
                                secret represents a secret that should populate this volume.
                                More info: https://kubernetes.io/docs/concepts/storage/volumes#secret
                                EOT
                                "properties" = {
                                  "defaultMode" = {
                                    "description" = <<-EOT
                                    defaultMode is Optional: mode bits used to set permissions on created files by default.
                                    Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
                                    YAML accepts both octal and decimal values, JSON requires decimal values
                                    for mode bits. Defaults to 0644.
                                    Directories within the path are not affected by this setting.
                                    This might be in conflict with other options that affect the file
                                    mode, like fsGroup, and the result can be other mode bits set.
                                    EOT
                                    "format"      = "int32"
                                    "type"        = "integer"
                                  }
                                  "items" = {
                                    "description" = <<-EOT
                                    items If unspecified, each key-value pair in the Data field of the referenced
                                    Secret will be projected into the volume as a file whose name is the
                                    key and content is the value. If specified, the listed keys will be
                                    projected into the specified paths, and unlisted keys will not be
                                    present. If a key is specified which is not present in the Secret,
                                    the volume setup will error unless it is marked optional. Paths must be
                                    relative and may not contain the '..' path or start with '..'.
                                    EOT
                                    "items" = {
                                      "description" = "Maps a string key to a path within a volume."
                                      "properties" = {
                                        "key" = {
                                          "description" = "key is the key to project."
                                          "type"        = "string"
                                        }
                                        "mode" = {
                                          "description" = <<-EOT
                                          mode is Optional: mode bits used to set permissions on this file.
                                          Must be an octal value between 0000 and 0777 or a decimal value between 0 and 511.
                                          YAML accepts both octal and decimal values, JSON requires decimal values for mode bits.
                                          If not specified, the volume defaultMode will be used.
                                          This might be in conflict with other options that affect the file
                                          mode, like fsGroup, and the result can be other mode bits set.
                                          EOT
                                          "format"      = "int32"
                                          "type"        = "integer"
                                        }
                                        "path" = {
                                          "description" = <<-EOT
                                          path is the relative path of the file to map the key to.
                                          May not be an absolute path.
                                          May not contain the path element '..'.
                                          May not start with the string '..'.
                                          EOT
                                          "type"        = "string"
                                        }
                                      }
                                      "required" = [
                                        "key",
                                        "path",
                                      ]
                                      "type" = "object"
                                    }
                                    "type"                   = "array"
                                    "x-kubernetes-list-type" = "atomic"
                                  }
                                  "optional" = {
                                    "description" = "optional field specify whether the Secret or its keys must be defined"
                                    "type"        = "boolean"
                                  }
                                  "secretName" = {
                                    "description" = <<-EOT
                                    secretName is the name of the secret in the pod's namespace to use.
                                    More info: https://kubernetes.io/docs/concepts/storage/volumes#secret
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "type" = "object"
                              }
                              "storageos" = {
                                "description" = <<-EOT
                                storageOS represents a StorageOS volume attached and mounted on Kubernetes nodes.
                                Deprecated: StorageOS is deprecated and the in-tree storageos type is no longer supported.
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is the filesystem type to mount.
                                    Must be a filesystem type supported by the host operating system.
                                    Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "readOnly" = {
                                    "description" = <<-EOT
                                    readOnly defaults to false (read/write). ReadOnly here will force
                                    the ReadOnly setting in VolumeMounts.
                                    EOT
                                    "type"        = "boolean"
                                  }
                                  "secretRef" = {
                                    "description" = <<-EOT
                                    secretRef specifies the secret to use for obtaining the StorageOS API
                                    credentials.  If not specified, default values will be attempted.
                                    EOT
                                    "properties" = {
                                      "name" = {
                                        "default"     = ""
                                        "description" = <<-EOT
                                        Name of the referent.
                                        This field is effectively required, but due to backwards compatibility is
                                        allowed to be empty. Instances of this type with an empty value here are
                                        almost certainly wrong.
                                        More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                        EOT
                                        "type"        = "string"
                                      }
                                    }
                                    "type"                  = "object"
                                    "x-kubernetes-map-type" = "atomic"
                                  }
                                  "volumeName" = {
                                    "description" = <<-EOT
                                    volumeName is the human-readable name of the StorageOS volume.  Volume
                                    names are only unique within a namespace.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "volumeNamespace" = {
                                    "description" = <<-EOT
                                    volumeNamespace specifies the scope of the volume within StorageOS.  If no
                                    namespace is specified then the Pod's namespace will be used.  This allows the
                                    Kubernetes name scoping to be mirrored within StorageOS for tighter integration.
                                    Set VolumeName to any name to override the default behaviour.
                                    Set to "default" if you are not using namespaces within StorageOS.
                                    Namespaces that do not pre-exist within StorageOS will be created.
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "type" = "object"
                              }
                              "vsphereVolume" = {
                                "description" = <<-EOT
                                vsphereVolume represents a vSphere volume attached and mounted on kubelets host machine.
                                Deprecated: VsphereVolume is deprecated. All operations for the in-tree vsphereVolume type
                                are redirected to the csi.vsphere.vmware.com CSI driver.
                                EOT
                                "properties" = {
                                  "fsType" = {
                                    "description" = <<-EOT
                                    fsType is filesystem type to mount.
                                    Must be a filesystem type supported by the host operating system.
                                    Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "storagePolicyID" = {
                                    "description" = "storagePolicyID is the storage Policy Based Management (SPBM) profile ID associated with the StoragePolicyName."
                                    "type"        = "string"
                                  }
                                  "storagePolicyName" = {
                                    "description" = "storagePolicyName is the storage Policy Based Management (SPBM) profile name."
                                    "type"        = "string"
                                  }
                                  "volumePath" = {
                                    "description" = "volumePath is the path that identifies vSphere volume vmdk"
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "volumePath",
                                ]
                                "type" = "object"
                              }
                            }
                            "required" = [
                              "name",
                            ]
                            "type" = "object"
                          }
                          "type" = "array"
                        }
                        "logLevel" = {
                          "description" = <<-EOT
                          LogLevel sets the log level for Envoy.
                          Allowed values are "trace", "debug", "info", "warn", "error", "critical", "off".
                          EOT
                          "type"        = "string"
                        }
                        "networkPublishing" = {
                          "description" = "NetworkPublishing defines how to expose Envoy to a network."
                          "properties" = {
                            "externalTrafficPolicy" = {
                              "description" = <<-EOT
                              ExternalTrafficPolicy describes how nodes distribute service traffic they
                              receive on one of the Service's "externally-facing" addresses (NodePorts, ExternalIPs,
                              and LoadBalancer IPs).
                              If unset, defaults to "Local".
                              EOT
                              "type"        = "string"
                            }
                            "ipFamilyPolicy" = {
                              "description" = <<-EOT
                              IPFamilyPolicy represents the dual-stack-ness requested or required by
                              this Service. If there is no value provided, then this field will be set
                              to SingleStack. Services can be "SingleStack" (a single IP family),
                              "PreferDualStack" (two IP families on dual-stack configured clusters or
                              a single IP family on single-stack clusters), or "RequireDualStack"
                              (two IP families on dual-stack configured clusters, otherwise fail).
                              EOT
                              "type"        = "string"
                            }
                            "serviceAnnotations" = {
                              "additionalProperties" = {
                                "type" = "string"
                              }
                              "description" = <<-EOT
                              ServiceAnnotations is the annotations to add to
                              the provisioned Envoy service.
                              EOT
                              "type"        = "object"
                            }
                            "type" = {
                              "description" = <<-EOT
                              NetworkPublishingType is the type of publishing strategy to use. Valid values are:
                              * LoadBalancerService
                              In this configuration, network endpoints for Envoy use container networking.
                              A Kubernetes LoadBalancer Service is created to publish Envoy network
                              endpoints.
                              See: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
                              * NodePortService
                              Publishes Envoy network endpoints using a Kubernetes NodePort Service.
                              In this configuration, Envoy network endpoints use container networking. A Kubernetes
                              NodePort Service is created to publish the network endpoints.
                              See: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport
                              NOTE:
                              When provisioning an Envoy `NodePortService`, use Gateway Listeners' port numbers to populate
                              the Service's node port values, there's no way to auto-allocate them.
                              See: https://github.com/projectcontour/contour/issues/4499
                              * ClusterIPService
                              Publishes Envoy network endpoints using a Kubernetes ClusterIP Service.
                              In this configuration, Envoy network endpoints use container networking. A Kubernetes
                              ClusterIP Service is created to publish the network endpoints.
                              See: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
                              If unset, defaults to LoadBalancerService.
                              EOT
                              "type"        = "string"
                            }
                          }
                          "type" = "object"
                        }
                        "nodePlacement" = {
                          "description" = "NodePlacement describes node scheduling configuration of Envoy pods."
                          "properties" = {
                            "nodeSelector" = {
                              "additionalProperties" = {
                                "type" = "string"
                              }
                              "description" = <<-EOT
                              NodeSelector is the simplest recommended form of node selection constraint
                              and specifies a map of key-value pairs. For the pod to be eligible
                              to run on a node, the node must have each of the indicated key-value pairs
                              as labels (it can have additional labels as well).
                              If unset, the pod(s) will be scheduled to any available node.
                              EOT
                              "type"        = "object"
                            }
                            "tolerations" = {
                              "description" = <<-EOT
                              Tolerations work with taints to ensure that pods are not scheduled
                              onto inappropriate nodes. One or more taints are applied to a node; this
                              marks that the node should not accept any pods that do not tolerate the
                              taints.
                              The default is an empty list.
                              See https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
                              for additional details.
                              EOT
                              "items" = {
                                "description" = <<-EOT
                                The pod this Toleration is attached to tolerates any taint that matches
                                the triple <key,value,effect> using the matching operator <operator>.
                                EOT
                                "properties" = {
                                  "effect" = {
                                    "description" = <<-EOT
                                    Effect indicates the taint effect to match. Empty means match all taint effects.
                                    When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "key" = {
                                    "description" = <<-EOT
                                    Key is the taint key that the toleration applies to. Empty means match all taint keys.
                                    If the key is empty, operator must be Exists; this combination means to match all values and all keys.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "operator" = {
                                    "description" = <<-EOT
                                    Operator represents a key's relationship to the value.
                                    Valid operators are Exists and Equal. Defaults to Equal.
                                    Exists is equivalent to wildcard for value, so that a pod can
                                    tolerate all taints of a particular category.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "tolerationSeconds" = {
                                    "description" = <<-EOT
                                    TolerationSeconds represents the period of time the toleration (which must be
                                    of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
                                    it is not set, which means tolerate the taint forever (do not evict). Zero and
                                    negative values will be treated as 0 (evict immediately) by the system.
                                    EOT
                                    "format"      = "int64"
                                    "type"        = "integer"
                                  }
                                  "value" = {
                                    "description" = <<-EOT
                                    Value is the taint value the toleration matches to.
                                    If the operator is Exists, the value should be empty, otherwise just a regular string.
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "type" = "object"
                              }
                              "type" = "array"
                            }
                          }
                          "type" = "object"
                        }
                        "overloadMaxDownstreamConnections" = {
                          "description" = <<-EOT
                          OverloadMaxDownstreamConn defines the envoy global downstream connection limit controlled by the overload manager.
                          When the value is greater than 0 the overload manager is enabled and listeners
                          will begin rejecting connections when the the connection threshold is hit.
                          Metrics and health listeners are not subject to the connection limits, however,
                          they still count against the global limit.
                          EOT
                          "format"      = "int64"
                          "type"        = "integer"
                        }
                        "overloadMaxHeapSize" = {
                          "description" = <<-EOT
                          OverloadMaxHeapSize defines the maximum heap memory of the envoy controlled by the overload manager.
                          When the value is greater than 0, the overload manager is enabled,
                          and when envoy reaches 95% of the maximum heap size, it performs a shrink heap operation,
                          When it reaches 98% of the maximum heap size, Envoy Will stop accepting requests.
                          More info: https://projectcontour.io/docs/main/config/overload-manager/
                          EOT
                          "format"      = "int64"
                          "type"        = "integer"
                        }
                        "podAnnotations" = {
                          "additionalProperties" = {
                            "type" = "string"
                          }
                          "description" = <<-EOT
                          PodAnnotations defines annotations to add to the Envoy pods.
                          the annotations for Prometheus will be appended or overwritten with predefined value.
                          EOT
                          "type"        = "object"
                        }
                        "replicas" = {
                          "description" = <<-EOT
                          Deprecated: Use `DeploymentSettings.Replicas` instead.
                          Replicas is the desired number of Envoy replicas. If WorkloadType
                          is not "Deployment", this field is ignored. Otherwise, if unset,
                          defaults to 2.
                          if both `DeploymentSettings.Replicas` and this one is set, use `DeploymentSettings.Replicas`.
                          EOT
                          "format"      = "int32"
                          "minimum"     = 0
                          "type"        = "integer"
                        }
                        "resources" = {
                          "description" = <<-EOT
                          Compute Resources required by envoy container.
                          Cannot be updated.
                          More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                          EOT
                          "properties" = {
                            "claims" = {
                              "description" = <<-EOT
                              Claims lists the names of resources, defined in spec.resourceClaims,
                              that are used by this container.
                              This is an alpha field and requires enabling the
                              DynamicResourceAllocation feature gate.
                              This field is immutable. It can only be set for containers.
                              EOT
                              "items" = {
                                "description" = "ResourceClaim references one entry in PodSpec.ResourceClaims."
                                "properties" = {
                                  "name" = {
                                    "description" = <<-EOT
                                    Name must match the name of one entry in pod.spec.resourceClaims of
                                    the Pod where this field is used. It makes that resource available
                                    inside a container.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "request" = {
                                    "description" = <<-EOT
                                    Request is the name chosen for a request in the referenced claim.
                                    If empty, everything from the claim is made available, otherwise
                                    only the result of this request.
                                    EOT
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "name",
                                ]
                                "type" = "object"
                              }
                              "type" = "array"
                              "x-kubernetes-list-map-keys" = [
                                "name",
                              ]
                              "x-kubernetes-list-type" = "map"
                            }
                            "limits" = {
                              "additionalProperties" = {
                                "anyOf" = [
                                  {
                                    "type" = "integer"
                                  },
                                  {
                                    "type" = "string"
                                  },
                                ]
                                "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                "x-kubernetes-int-or-string" = true
                              }
                              "description" = <<-EOT
                              Limits describes the maximum amount of compute resources allowed.
                              More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                              EOT
                              "type"        = "object"
                            }
                            "requests" = {
                              "additionalProperties" = {
                                "anyOf" = [
                                  {
                                    "type" = "integer"
                                  },
                                  {
                                    "type" = "string"
                                  },
                                ]
                                "pattern"                    = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$"
                                "x-kubernetes-int-or-string" = true
                              }
                              "description" = <<-EOT
                              Requests describes the minimum amount of compute resources required.
                              If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
                              otherwise to an implementation-defined value. Requests cannot exceed Limits.
                              More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
                              EOT
                              "type"        = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "workloadType" = {
                          "description" = <<-EOT
                          WorkloadType is the type of workload to install Envoy
                          as. Choices are DaemonSet and Deployment. If unset, defaults
                          to DaemonSet.
                          EOT
                          "type"        = "string"
                        }
                      }
                      "type" = "object"
                    }
                    "resourceLabels" = {
                      "additionalProperties" = {
                        "type" = "string"
                      }
                      "description" = <<-EOT
                      ResourceLabels is a set of labels to add to the provisioned Contour resources.
                      Deprecated: use Gateway.Spec.Infrastructure.Labels instead. This field will be
                      removed in a future release.
                      EOT
                      "type"        = "object"
                    }
                    "runtimeSettings" = {
                      "description" = <<-EOT
                      RuntimeSettings is a ContourConfiguration spec to be used when
                      provisioning a Contour instance that will influence aspects of
                      the Contour instance's runtime behavior.
                      EOT
                      "properties" = {
                        "debug" = {
                          "description" = <<-EOT
                          Debug contains parameters to enable debug logging
                          and debug interfaces inside Contour.
                          EOT
                          "properties" = {
                            "address" = {
                              "description" = <<-EOT
                              Defines the Contour debug address interface.
                              Contour's default is "127.0.0.1".
                              EOT
                              "type"        = "string"
                            }
                            "port" = {
                              "description" = <<-EOT
                              Defines the Contour debug address port.
                              Contour's default is 6060.
                              EOT
                              "type"        = "integer"
                            }
                          }
                          "type" = "object"
                        }
                        "enableExternalNameService" = {
                          "description" = <<-EOT
                          EnableExternalNameService allows processing of ExternalNameServices
                          Contour's default is false for security reasons.
                          EOT
                          "type"        = "boolean"
                        }
                        "envoy" = {
                          "description" = <<-EOT
                          Envoy contains parameters for Envoy as well
                          as how to optionally configure a managed Envoy fleet.
                          EOT
                          "properties" = {
                            "clientCertificate" = {
                              "description" = <<-EOT
                              ClientCertificate defines the namespace/name of the Kubernetes
                              secret containing the client certificate and private key
                              to be used when establishing TLS connection to upstream
                              cluster.
                              EOT
                              "properties" = {
                                "name" = {
                                  "type" = "string"
                                }
                                "namespace" = {
                                  "type" = "string"
                                }
                              }
                              "required" = [
                                "name",
                                "namespace",
                              ]
                              "type" = "object"
                            }
                            "cluster" = {
                              "description" = <<-EOT
                              Cluster holds various configurable Envoy cluster values that can
                              be set in the config file.
                              EOT
                              "properties" = {
                                "circuitBreakers" = {
                                  "description" = <<-EOT
                                  GlobalCircuitBreakerDefaults specifies default circuit breaker budget across all services.
                                  If defined, this will be used as the default for all services.
                                  EOT
                                  "properties" = {
                                    "maxConnections" = {
                                      "description" = "The maximum number of connections that a single Envoy instance allows to the Kubernetes Service; defaults to 1024."
                                      "format"      = "int32"
                                      "type"        = "integer"
                                    }
                                    "maxPendingRequests" = {
                                      "description" = "The maximum number of pending requests that a single Envoy instance allows to the Kubernetes Service; defaults to 1024."
                                      "format"      = "int32"
                                      "type"        = "integer"
                                    }
                                    "maxRequests" = {
                                      "description" = "The maximum parallel requests a single Envoy instance allows to the Kubernetes Service; defaults to 1024"
                                      "format"      = "int32"
                                      "type"        = "integer"
                                    }
                                    "maxRetries" = {
                                      "description" = "The maximum number of parallel retries a single Envoy instance allows to the Kubernetes Service; defaults to 3."
                                      "format"      = "int32"
                                      "type"        = "integer"
                                    }
                                    "perHostMaxConnections" = {
                                      "description" = <<-EOT
                                      PerHostMaxConnections is the maximum number of connections
                                      that Envoy will allow to each individual host in a cluster.
                                      EOT
                                      "format"      = "int32"
                                      "type"        = "integer"
                                    }
                                  }
                                  "type" = "object"
                                }
                                "dnsLookupFamily" = {
                                  "description" = <<-EOT
                                  DNSLookupFamily defines how external names are looked up
                                  When configured as V4, the DNS resolver will only perform a lookup
                                  for addresses in the IPv4 family. If V6 is configured, the DNS resolver
                                  will only perform a lookup for addresses in the IPv6 family.
                                  If AUTO is configured, the DNS resolver will first perform a lookup
                                  for addresses in the IPv6 family and fallback to a lookup for addresses
                                  in the IPv4 family. If ALL is specified, the DNS resolver will perform a lookup for
                                  both IPv4 and IPv6 families, and return all resolved addresses.
                                  When this is used, Happy Eyeballs will be enabled for upstream connections.
                                  Refer to Happy Eyeballs Support for more information.
                                  Note: This only applies to externalName clusters.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/cluster/v3/cluster.proto.html#envoy-v3-api-enum-config-cluster-v3-cluster-dnslookupfamily
                                  for more information.
                                  Values: `auto` (default), `v4`, `v6`, `all`.
                                  Other values will produce an error.
                                  EOT
                                  "type"        = "string"
                                }
                                "maxRequestsPerConnection" = {
                                  "description" = <<-EOT
                                  Defines the maximum requests for upstream connections. If not specified, there is no limit.
                                  see https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/core/v3/protocol.proto#envoy-v3-api-msg-config-core-v3-httpprotocoloptions
                                  for more information.
                                  EOT
                                  "format"      = "int32"
                                  "minimum"     = 1
                                  "type"        = "integer"
                                }
                                "per-connection-buffer-limit-bytes" = {
                                  "description" = <<-EOT
                                  Defines the soft limit on size of the cluster’s new connection read and write buffers in bytes.
                                  If unspecified, an implementation defined default is applied (1MiB).
                                  see https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/cluster/v3/cluster.proto#envoy-v3-api-field-config-cluster-v3-cluster-per-connection-buffer-limit-bytes
                                  for more information.
                                  EOT
                                  "format"      = "int32"
                                  "minimum"     = 1
                                  "type"        = "integer"
                                }
                                "upstreamTLS" = {
                                  "description" = "UpstreamTLS contains the TLS policy parameters for upstream connections"
                                  "properties" = {
                                    "cipherSuites" = {
                                      "description" = <<-EOT
                                      CipherSuites defines the TLS ciphers to be supported by Envoy TLS
                                      listeners when negotiating TLS 1.2. Ciphers are validated against the
                                      set that Envoy supports by default. This parameter should only be used
                                      by advanced users. Note that these will be ignored when TLS 1.3 is in
                                      use.
                                      This field is optional; when it is undefined, a Contour-managed ciphersuite list
                                      will be used, which may be updated to keep it secure.
                                      Contour's default list is:
                                        - "[ECDHE-ECDSA-AES128-GCM-SHA256|ECDHE-ECDSA-CHACHA20-POLY1305]"
                                        - "[ECDHE-RSA-AES128-GCM-SHA256|ECDHE-RSA-CHACHA20-POLY1305]"
                                        - "ECDHE-ECDSA-AES256-GCM-SHA384"
                                        - "ECDHE-RSA-AES256-GCM-SHA384"
                                      Ciphers provided are validated against the following list:
                                        - "[ECDHE-ECDSA-AES128-GCM-SHA256|ECDHE-ECDSA-CHACHA20-POLY1305]"
                                        - "[ECDHE-RSA-AES128-GCM-SHA256|ECDHE-RSA-CHACHA20-POLY1305]"
                                        - "ECDHE-ECDSA-AES128-GCM-SHA256"
                                        - "ECDHE-RSA-AES128-GCM-SHA256"
                                        - "ECDHE-ECDSA-AES128-SHA"
                                        - "ECDHE-RSA-AES128-SHA"
                                        - "AES128-GCM-SHA256"
                                        - "AES128-SHA"
                                        - "ECDHE-ECDSA-AES256-GCM-SHA384"
                                        - "ECDHE-RSA-AES256-GCM-SHA384"
                                        - "ECDHE-ECDSA-AES256-SHA"
                                        - "ECDHE-RSA-AES256-SHA"
                                        - "AES256-GCM-SHA384"
                                        - "AES256-SHA"
                                      Contour recommends leaving this undefined unless you are sure you must.
                                      See: https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/transport_sockets/tls/v3/common.proto#extensions-transport-sockets-tls-v3-tlsparameters
                                      Note: This list is a superset of what is valid for stock Envoy builds and those using BoringSSL FIPS.
                                      EOT
                                      "items" = {
                                        "type" = "string"
                                      }
                                      "type" = "array"
                                    }
                                    "maximumProtocolVersion" = {
                                      "description" = <<-EOT
                                      MaximumProtocolVersion is the maximum TLS version this vhost should
                                      negotiate.
                                      Values: `1.2`, `1.3`(default).
                                      Other values will produce an error.
                                      EOT
                                      "type"        = "string"
                                    }
                                    "minimumProtocolVersion" = {
                                      "description" = <<-EOT
                                      MinimumProtocolVersion is the minimum TLS version this vhost should
                                      negotiate.
                                      Values: `1.2` (default), `1.3`.
                                      Other values will produce an error.
                                      EOT
                                      "type"        = "string"
                                    }
                                  }
                                  "type" = "object"
                                }
                              }
                              "type" = "object"
                            }
                            "defaultHTTPVersions" = {
                              "description" = <<-EOT
                              DefaultHTTPVersions defines the default set of HTTPS
                              versions the proxy should accept. HTTP versions are
                              strings of the form "HTTP/xx". Supported versions are
                              "HTTP/1.1" and "HTTP/2".
                              Values: `HTTP/1.1`, `HTTP/2` (default: both).
                              Other values will produce an error.
                              EOT
                              "items" = {
                                "description" = "HTTPVersionType is the name of a supported HTTP version."
                                "type"        = "string"
                              }
                              "type" = "array"
                            }
                            "health" = {
                              "description" = <<-EOT
                              Health defines the endpoint Envoy uses to serve health checks.
                              Contour's default is { address: "0.0.0.0", port: 8002 }.
                              EOT
                              "properties" = {
                                "address" = {
                                  "description" = "Defines the health address interface."
                                  "minLength"   = 1
                                  "type"        = "string"
                                }
                                "port" = {
                                  "description" = "Defines the health port."
                                  "type"        = "integer"
                                }
                              }
                              "type" = "object"
                            }
                            "http" = {
                              "description" = <<-EOT
                              Defines the HTTP Listener for Envoy.
                              Contour's default is { address: "0.0.0.0", port: 8080, accessLog: "/dev/stdout" }.
                              EOT
                              "properties" = {
                                "accessLog" = {
                                  "description" = "AccessLog defines where Envoy logs are outputted for this listener."
                                  "type"        = "string"
                                }
                                "address" = {
                                  "description" = "Defines an Envoy Listener Address."
                                  "minLength"   = 1
                                  "type"        = "string"
                                }
                                "port" = {
                                  "description" = "Defines an Envoy listener Port."
                                  "type"        = "integer"
                                }
                              }
                              "type" = "object"
                            }
                            "https" = {
                              "description" = <<-EOT
                              Defines the HTTPS Listener for Envoy.
                              Contour's default is { address: "0.0.0.0", port: 8443, accessLog: "/dev/stdout" }.
                              EOT
                              "properties" = {
                                "accessLog" = {
                                  "description" = "AccessLog defines where Envoy logs are outputted for this listener."
                                  "type"        = "string"
                                }
                                "address" = {
                                  "description" = "Defines an Envoy Listener Address."
                                  "minLength"   = 1
                                  "type"        = "string"
                                }
                                "port" = {
                                  "description" = "Defines an Envoy listener Port."
                                  "type"        = "integer"
                                }
                              }
                              "type" = "object"
                            }
                            "listener" = {
                              "description" = "Listener hold various configurable Envoy listener values."
                              "properties" = {
                                "compression" = {
                                  "description" = "Compression defines configuration related to compression in the default HTTP Listener filters."
                                  "properties" = {
                                    "algorithm" = {
                                      "description" = <<-EOT
                                      Algorithm selects the response compression type applied in the compression HTTP filter of the default Listener filters.
                                      Values: `gzip` (default), `brotli`, `zstd`, `disabled`.
                                      Setting this to `disabled` will make Envoy skip "Accept-Encoding: gzip,deflate" request header and always return uncompressed response.
                                      EOT
                                      "enum" = [
                                        "gzip",
                                        "brotli",
                                        "zstd",
                                        "disabled",
                                      ]
                                      "type" = "string"
                                    }
                                  }
                                  "type" = "object"
                                }
                                "connectionBalancer" = {
                                  "description" = <<-EOT
                                  ConnectionBalancer. If the value is exact, the listener will use the exact connection balancer
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v2/api/v2/listener.proto#envoy-api-msg-listener-connectionbalanceconfig
                                  for more information.
                                  Values: (empty string): use the default ConnectionBalancer, `exact`: use the Exact ConnectionBalancer.
                                  Other values will produce an error.
                                  EOT
                                  "type"        = "string"
                                }
                                "disableAllowChunkedLength" = {
                                  "description" = <<-EOT
                                  DisableAllowChunkedLength disables the RFC-compliant Envoy behavior to
                                  strip the "Content-Length" header if "Transfer-Encoding: chunked" is
                                  also set. This is an emergency off-switch to revert back to Envoy's
                                  default behavior in case of failures. Please file an issue if failures
                                  are encountered.
                                  See: https://github.com/projectcontour/contour/issues/3221
                                  Contour's default is false.
                                  EOT
                                  "type"        = "boolean"
                                }
                                "disableMergeSlashes" = {
                                  "description" = <<-EOT
                                  DisableMergeSlashes disables Envoy's non-standard merge_slashes path transformation option
                                  which strips duplicate slashes from request URL paths.
                                  Contour's default is false.
                                  EOT
                                  "type"        = "boolean"
                                }
                                "httpMaxConcurrentStreams" = {
                                  "description" = <<-EOT
                                  Defines the value for SETTINGS_MAX_CONCURRENT_STREAMS Envoy will advertise in the
                                  SETTINGS frame in HTTP/2 connections and the limit for concurrent streams allowed
                                  for a peer on a single HTTP/2 connection. It is recommended to not set this lower
                                  than 100 but this field can be used to bound resource usage by HTTP/2 connections
                                  and mitigate attacks like CVE-2023-44487. The default value when this is not set is
                                  unlimited.
                                  EOT
                                  "format"      = "int32"
                                  "minimum"     = 1
                                  "type"        = "integer"
                                }
                                "maxConnectionsPerListener" = {
                                  "description" = <<-EOT
                                  Defines the limit on number of active connections to a listener. The limit is applied
                                  per listener. The default value when this is not set is unlimited.
                                  EOT
                                  "format"      = "int32"
                                  "minimum"     = 1
                                  "type"        = "integer"
                                }
                                "maxRequestsPerConnection" = {
                                  "description" = <<-EOT
                                  Defines the maximum requests for downstream connections. If not specified, there is no limit.
                                  see https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/core/v3/protocol.proto#envoy-v3-api-msg-config-core-v3-httpprotocoloptions
                                  for more information.
                                  EOT
                                  "format"      = "int32"
                                  "minimum"     = 1
                                  "type"        = "integer"
                                }
                                "maxRequestsPerIOCycle" = {
                                  "description" = <<-EOT
                                  Defines the limit on number of HTTP requests that Envoy will process from a single
                                  connection in a single I/O cycle. Requests over this limit are processed in subsequent
                                  I/O cycles. Can be used as a mitigation for CVE-2023-44487 when abusive traffic is
                                  detected. Configures the http.max_requests_per_io_cycle Envoy runtime setting. The default
                                  value when this is not set is no limit.
                                  EOT
                                  "format"      = "int32"
                                  "minimum"     = 1
                                  "type"        = "integer"
                                }
                                "per-connection-buffer-limit-bytes" = {
                                  "description" = <<-EOT
                                  Defines the soft limit on size of the listener’s new connection read and write buffers in bytes.
                                  If unspecified, an implementation defined default is applied (1MiB).
                                  see https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/listener/v3/listener.proto#envoy-v3-api-field-config-listener-v3-listener-per-connection-buffer-limit-bytes
                                  for more information.
                                  EOT
                                  "format"      = "int32"
                                  "minimum"     = 1
                                  "type"        = "integer"
                                }
                                "serverHeaderTransformation" = {
                                  "description" = <<-EOT
                                  Defines the action to be applied to the Server header on the response path.
                                  When configured as overwrite, overwrites any Server header with "envoy".
                                  When configured as append_if_absent, if a Server header is present, pass it through, otherwise set it to "envoy".
                                  When configured as pass_through, pass through the value of the Server header, and do not append a header if none is present.
                                  Values: `overwrite` (default), `append_if_absent`, `pass_through`
                                  Other values will produce an error.
                                  Contour's default is overwrite.
                                  EOT
                                  "type"        = "string"
                                }
                                "socketOptions" = {
                                  "description" = <<-EOT
                                  SocketOptions defines configurable socket options for the listeners.
                                  Single set of options are applied to all listeners.
                                  EOT
                                  "properties" = {
                                    "tos" = {
                                      "description" = <<-EOT
                                      Defines the value for IPv4 TOS field (including 6 bit DSCP field) for IP packets originating from Envoy listeners.
                                      Single value is applied to all listeners.
                                      If listeners are bound to IPv6-only addresses, setting this option will cause an error.
                                      EOT
                                      "format"      = "int32"
                                      "maximum"     = 255
                                      "minimum"     = 0
                                      "type"        = "integer"
                                    }
                                    "trafficClass" = {
                                      "description" = <<-EOT
                                      Defines the value for IPv6 Traffic Class field (including 6 bit DSCP field) for IP packets originating from the Envoy listeners.
                                      Single value is applied to all listeners.
                                      If listeners are bound to IPv4-only addresses, setting this option will cause an error.
                                      EOT
                                      "format"      = "int32"
                                      "maximum"     = 255
                                      "minimum"     = 0
                                      "type"        = "integer"
                                    }
                                  }
                                  "type" = "object"
                                }
                                "tls" = {
                                  "description" = "TLS holds various configurable Envoy TLS listener values."
                                  "properties" = {
                                    "cipherSuites" = {
                                      "description" = <<-EOT
                                      CipherSuites defines the TLS ciphers to be supported by Envoy TLS
                                      listeners when negotiating TLS 1.2. Ciphers are validated against the
                                      set that Envoy supports by default. This parameter should only be used
                                      by advanced users. Note that these will be ignored when TLS 1.3 is in
                                      use.
                                      This field is optional; when it is undefined, a Contour-managed ciphersuite list
                                      will be used, which may be updated to keep it secure.
                                      Contour's default list is:
                                        - "[ECDHE-ECDSA-AES128-GCM-SHA256|ECDHE-ECDSA-CHACHA20-POLY1305]"
                                        - "[ECDHE-RSA-AES128-GCM-SHA256|ECDHE-RSA-CHACHA20-POLY1305]"
                                        - "ECDHE-ECDSA-AES256-GCM-SHA384"
                                        - "ECDHE-RSA-AES256-GCM-SHA384"
                                      Ciphers provided are validated against the following list:
                                        - "[ECDHE-ECDSA-AES128-GCM-SHA256|ECDHE-ECDSA-CHACHA20-POLY1305]"
                                        - "[ECDHE-RSA-AES128-GCM-SHA256|ECDHE-RSA-CHACHA20-POLY1305]"
                                        - "ECDHE-ECDSA-AES128-GCM-SHA256"
                                        - "ECDHE-RSA-AES128-GCM-SHA256"
                                        - "ECDHE-ECDSA-AES128-SHA"
                                        - "ECDHE-RSA-AES128-SHA"
                                        - "AES128-GCM-SHA256"
                                        - "AES128-SHA"
                                        - "ECDHE-ECDSA-AES256-GCM-SHA384"
                                        - "ECDHE-RSA-AES256-GCM-SHA384"
                                        - "ECDHE-ECDSA-AES256-SHA"
                                        - "ECDHE-RSA-AES256-SHA"
                                        - "AES256-GCM-SHA384"
                                        - "AES256-SHA"
                                      Contour recommends leaving this undefined unless you are sure you must.
                                      See: https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/transport_sockets/tls/v3/common.proto#extensions-transport-sockets-tls-v3-tlsparameters
                                      Note: This list is a superset of what is valid for stock Envoy builds and those using BoringSSL FIPS.
                                      EOT
                                      "items" = {
                                        "type" = "string"
                                      }
                                      "type" = "array"
                                    }
                                    "maximumProtocolVersion" = {
                                      "description" = <<-EOT
                                      MaximumProtocolVersion is the maximum TLS version this vhost should
                                      negotiate.
                                      Values: `1.2`, `1.3`(default).
                                      Other values will produce an error.
                                      EOT
                                      "type"        = "string"
                                    }
                                    "minimumProtocolVersion" = {
                                      "description" = <<-EOT
                                      MinimumProtocolVersion is the minimum TLS version this vhost should
                                      negotiate.
                                      Values: `1.2` (default), `1.3`.
                                      Other values will produce an error.
                                      EOT
                                      "type"        = "string"
                                    }
                                  }
                                  "type" = "object"
                                }
                                "useProxyProtocol" = {
                                  "description" = <<-EOT
                                  Use PROXY protocol for all listeners.
                                  Contour's default is false.
                                  EOT
                                  "type"        = "boolean"
                                }
                              }
                              "type" = "object"
                            }
                            "logging" = {
                              "description" = "Logging defines how Envoy's logs can be configured."
                              "properties" = {
                                "accessLogFormat" = {
                                  "description" = <<-EOT
                                  AccessLogFormat sets the global access log format.
                                  Values: `envoy` (default), `json`.
                                  Other values will produce an error.
                                  EOT
                                  "type"        = "string"
                                }
                                "accessLogFormatString" = {
                                  "description" = <<-EOT
                                  AccessLogFormatString sets the access log format when format is set to `envoy`.
                                  When empty, Envoy's default format is used.
                                  EOT
                                  "type"        = "string"
                                }
                                "accessLogJSONFields" = {
                                  "description" = <<-EOT
                                  AccessLogJSONFields sets the fields that JSON logging will
                                  output when AccessLogFormat is json.
                                  EOT
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "type" = "array"
                                }
                                "accessLogLevel" = {
                                  "description" = <<-EOT
                                  AccessLogLevel sets the verbosity level of the access log.
                                  Values: `info` (default, all requests are logged), `error` (all non-success requests, i.e. 300+ response code, are logged), `critical` (all 5xx requests are logged) and `disabled`.
                                  Other values will produce an error.
                                  EOT
                                  "type"        = "string"
                                }
                              }
                              "type" = "object"
                            }
                            "metrics" = {
                              "description" = <<-EOT
                              Metrics defines the endpoint Envoy uses to serve metrics.
                              Contour's default is { address: "0.0.0.0", port: 8002 }.
                              EOT
                              "properties" = {
                                "address" = {
                                  "description" = "Defines the metrics address interface."
                                  "maxLength"   = 253
                                  "minLength"   = 1
                                  "type"        = "string"
                                }
                                "port" = {
                                  "description" = "Defines the metrics port."
                                  "type"        = "integer"
                                }
                                "tls" = {
                                  "description" = <<-EOT
                                  TLS holds TLS file config details.
                                  Metrics and health endpoints cannot have same port number when metrics is served over HTTPS.
                                  EOT
                                  "properties" = {
                                    "caFile" = {
                                      "description" = "CA filename."
                                      "type"        = "string"
                                    }
                                    "certFile" = {
                                      "description" = "Client certificate filename."
                                      "type"        = "string"
                                    }
                                    "keyFile" = {
                                      "description" = "Client key filename."
                                      "type"        = "string"
                                    }
                                  }
                                  "type" = "object"
                                }
                              }
                              "type" = "object"
                            }
                            "network" = {
                              "description" = "Network holds various configurable Envoy network values."
                              "properties" = {
                                "adminPort" = {
                                  "description" = <<-EOT
                                  Configure the port used to access the Envoy Admin interface.
                                  If configured to port "0" then the admin interface is disabled.
                                  Contour's default is 9001.
                                  EOT
                                  "type"        = "integer"
                                }
                                "numTrustedHops" = {
                                  "description" = <<-EOT
                                  XffNumTrustedHops defines the number of additional ingress proxy hops from the
                                  right side of the x-forwarded-for HTTP header to trust when determining the origin
                                  client’s IP address.
                                  See https://www.envoyproxy.io/docs/envoy/v1.17.0/api-v3/extensions/filters/network/http_connection_manager/v3/http_connection_manager.proto?highlight=xff_num_trusted_hops
                                  for more information.
                                  Contour's default is 0.
                                  EOT
                                  "format"      = "int32"
                                  "type"        = "integer"
                                }
                                "stripTrailingHostDot" = {
                                  "description" = <<-EOT
                                  EnvoyStripTrailingHostDot defines if trailing dot of the host should be removed from host/authority header
                                  before any processing of request by HTTP filters or routing. This
                                  affects the upstream host header. Without setting this option to true, incoming
                                  requests with host example.com. will not match against route with domains
                                  match set to example.com.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/http_connection_manager/v3/http_connection_manager.proto?highlight=strip_trailing_host_dot
                                  for more information.
                                  Contour's default is false.
                                  EOT
                                  "type"        = "boolean"
                                }
                              }
                              "type" = "object"
                            }
                            "omEnforcedHealth" = {
                              "description" = <<-EOT
                              OMEnforcedHealth defines the endpoint Envoy uses to serve health checks with
                              the envoy overload manager actions, such as global connection limits, enforced.
                              The configured values must be different from the endpoints
                              configured by [EnvoyConfig.Metrics] and [EnvoyConfig.Health]
                              This is disabled by default
                              EOT
                              "properties" = {
                                "address" = {
                                  "description" = "Defines the health address interface."
                                  "minLength"   = 1
                                  "type"        = "string"
                                }
                                "port" = {
                                  "description" = "Defines the health port."
                                  "type"        = "integer"
                                }
                              }
                              "type" = "object"
                            }
                            "service" = {
                              "description" = <<-EOT
                              Service holds Envoy service parameters for setting Ingress status.
                              Contour's default is { namespace: "projectcontour", name: "envoy" }.
                              EOT
                              "properties" = {
                                "name" = {
                                  "type" = "string"
                                }
                                "namespace" = {
                                  "type" = "string"
                                }
                              }
                              "required" = [
                                "name",
                                "namespace",
                              ]
                              "type" = "object"
                            }
                            "timeouts" = {
                              "description" = <<-EOT
                              Timeouts holds various configurable timeouts that can
                              be set in the config file.
                              EOT
                              "properties" = {
                                "connectTimeout" = {
                                  "description" = <<-EOT
                                  ConnectTimeout defines how long the proxy should wait when establishing connection to upstream service.
                                  If not set, a default value of 2 seconds will be used.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/cluster/v3/cluster.proto#envoy-v3-api-field-config-cluster-v3-cluster-connect-timeout
                                  for more information.
                                  EOT
                                  "type"        = "string"
                                }
                                "connectionIdleTimeout" = {
                                  "description" = <<-EOT
                                  ConnectionIdleTimeout defines how long the proxy should wait while there are
                                  no active requests (for HTTP/1.1) or streams (for HTTP/2) before terminating
                                  an HTTP connection. Set to "infinity" to disable the timeout entirely.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/core/v3/protocol.proto#envoy-v3-api-field-config-core-v3-httpprotocoloptions-idle-timeout
                                  for more information.
                                  EOT
                                  "type"        = "string"
                                }
                                "connectionShutdownGracePeriod" = {
                                  "description" = <<-EOT
                                  ConnectionShutdownGracePeriod defines how long the proxy will wait between sending an
                                  initial GOAWAY frame and a second, final GOAWAY frame when terminating an HTTP/2 connection.
                                  During this grace period, the proxy will continue to respond to new streams. After the final
                                  GOAWAY frame has been sent, the proxy will refuse new streams.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/http_connection_manager/v3/http_connection_manager.proto#envoy-v3-api-field-extensions-filters-network-http-connection-manager-v3-httpconnectionmanager-drain-timeout
                                  for more information.
                                  EOT
                                  "type"        = "string"
                                }
                                "delayedCloseTimeout" = {
                                  "description" = <<-EOT
                                  DelayedCloseTimeout defines how long envoy will wait, once connection
                                  close processing has been initiated, for the downstream peer to close
                                  the connection before Envoy closes the socket associated with the connection.
                                  Setting this timeout to 'infinity' will disable it, equivalent to setting it to '0'
                                  in Envoy. Leaving it unset will result in the Envoy default value being used.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/http_connection_manager/v3/http_connection_manager.proto#envoy-v3-api-field-extensions-filters-network-http-connection-manager-v3-httpconnectionmanager-delayed-close-timeout
                                  for more information.
                                  EOT
                                  "type"        = "string"
                                }
                                "maxConnectionDuration" = {
                                  "description" = <<-EOT
                                  MaxConnectionDuration defines the maximum period of time after an HTTP connection
                                  has been established from the client to the proxy before it is closed by the proxy,
                                  regardless of whether there has been activity or not. Omit or set to "infinity" for
                                  no max duration.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/core/v3/protocol.proto#envoy-v3-api-field-config-core-v3-httpprotocoloptions-max-connection-duration
                                  for more information.
                                  EOT
                                  "type"        = "string"
                                }
                                "requestTimeout" = {
                                  "description" = <<-EOT
                                  RequestTimeout sets the client request timeout globally for Contour. Note that
                                  this is a timeout for the entire request, not an idle timeout. Omit or set to
                                  "infinity" to disable the timeout entirely.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/http_connection_manager/v3/http_connection_manager.proto#envoy-v3-api-field-extensions-filters-network-http-connection-manager-v3-httpconnectionmanager-request-timeout
                                  for more information.
                                  EOT
                                  "type"        = "string"
                                }
                                "streamIdleTimeout" = {
                                  "description" = <<-EOT
                                  StreamIdleTimeout defines how long the proxy should wait while there is no
                                  request activity (for HTTP/1.1) or stream activity (for HTTP/2) before
                                  terminating the HTTP request or stream. Set to "infinity" to disable the
                                  timeout entirely.
                                  See https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/http_connection_manager/v3/http_connection_manager.proto#envoy-v3-api-field-extensions-filters-network-http-connection-manager-v3-httpconnectionmanager-stream-idle-timeout
                                  for more information.
                                  EOT
                                  "type"        = "string"
                                }
                              }
                              "type" = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "featureFlags" = {
                          "description" = "FeatureFlags defines toggle to enable new contour features."
                          "items" = {
                            "type" = "string"
                          }
                          "type" = "array"
                        }
                        "gateway" = {
                          "description" = <<-EOT
                          Gateway contains parameters for the gateway-api Gateway that Contour
                          is configured to serve traffic.
                          EOT
                          "properties" = {
                            "gatewayRef" = {
                              "description" = <<-EOT
                              GatewayRef defines the specific Gateway that this Contour
                              instance corresponds to.
                              EOT
                              "properties" = {
                                "name" = {
                                  "type" = "string"
                                }
                                "namespace" = {
                                  "type" = "string"
                                }
                              }
                              "required" = [
                                "name",
                                "namespace",
                              ]
                              "type" = "object"
                            }
                          }
                          "required" = [
                            "gatewayRef",
                          ]
                          "type" = "object"
                        }
                        "globalExtAuth" = {
                          "description" = <<-EOT
                          GlobalExternalAuthorization allows envoys external authorization filter
                          to be enabled for all virtual hosts.
                          EOT
                          "properties" = {
                            "authPolicy" = {
                              "description" = <<-EOT
                              AuthPolicy sets a default authorization policy for client requests.
                              This policy will be used unless overridden by individual routes.
                              EOT
                              "properties" = {
                                "context" = {
                                  "additionalProperties" = {
                                    "type" = "string"
                                  }
                                  "description" = <<-EOT
                                  Context is a set of key/value pairs that are sent to the
                                  authentication server in the check request. If a context
                                  is provided at an enclosing scope, the entries are merged
                                  such that the inner scope overrides matching keys from the
                                  outer scope.
                                  EOT
                                  "type"        = "object"
                                }
                                "disabled" = {
                                  "description" = <<-EOT
                                  When true, this field disables client request authentication
                                  for the scope of the policy.
                                  EOT
                                  "type"        = "boolean"
                                }
                              }
                              "type" = "object"
                            }
                            "extensionRef" = {
                              "description" = "ExtensionServiceRef specifies the extension resource that will authorize client requests."
                              "properties" = {
                                "apiVersion" = {
                                  "description" = <<-EOT
                                  API version of the referent.
                                  If this field is not specified, the default "projectcontour.io/v1alpha1" will be used
                                  EOT
                                  "minLength"   = 1
                                  "type"        = "string"
                                }
                                "name" = {
                                  "description" = <<-EOT
                                  Name of the referent.
                                  More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
                                  EOT
                                  "minLength"   = 1
                                  "type"        = "string"
                                }
                                "namespace" = {
                                  "description" = <<-EOT
                                  Namespace of the referent.
                                  If this field is not specifies, the namespace of the resource that targets the referent will be used.
                                  More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
                                  EOT
                                  "minLength"   = 1
                                  "type"        = "string"
                                }
                              }
                              "type" = "object"
                            }
                            "failOpen" = {
                              "description" = <<-EOT
                              If FailOpen is true, the client request is forwarded to the upstream service
                              even if the authorization server fails to respond. This field should not be
                              set in most cases. It is intended for use only while migrating applications
                              from internal authorization to Contour external authorization.
                              EOT
                              "type"        = "boolean"
                            }
                            "responseTimeout" = {
                              "description" = <<-EOT
                              ResponseTimeout configures maximum time to wait for a check response from the authorization server.
                              Timeout durations are expressed in the Go [Duration format](https://godoc.org/time#ParseDuration).
                              Valid time units are "ns", "us" (or "µs"), "ms", "s", "m", "h".
                              The string "infinity" is also a valid input and specifies no timeout.
                              EOT
                              "pattern"     = "^(((\\d*(\\.\\d*)?h)|(\\d*(\\.\\d*)?m)|(\\d*(\\.\\d*)?s)|(\\d*(\\.\\d*)?ms)|(\\d*(\\.\\d*)?us)|(\\d*(\\.\\d*)?µs)|(\\d*(\\.\\d*)?ns))+|infinity|infinite)$"
                              "type"        = "string"
                            }
                            "withRequestBody" = {
                              "description" = "WithRequestBody specifies configuration for sending the client request's body to authorization server."
                              "properties" = {
                                "allowPartialMessage" = {
                                  "description" = "If AllowPartialMessage is true, then Envoy will buffer the body until MaxRequestBytes are reached."
                                  "type"        = "boolean"
                                }
                                "maxRequestBytes" = {
                                  "default"     = 1024
                                  "description" = "MaxRequestBytes sets the maximum size of message body ExtAuthz filter will hold in-memory."
                                  "format"      = "int32"
                                  "minimum"     = 1
                                  "type"        = "integer"
                                }
                                "packAsBytes" = {
                                  "description" = "If PackAsBytes is true, the body sent to Authorization Server is in raw bytes."
                                  "type"        = "boolean"
                                }
                              }
                              "type" = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "health" = {
                          "description" = <<-EOT
                          Health defines the endpoints Contour uses to serve health checks.
                          Contour's default is { address: "0.0.0.0", port: 8000 }.
                          EOT
                          "properties" = {
                            "address" = {
                              "description" = "Defines the health address interface."
                              "minLength"   = 1
                              "type"        = "string"
                            }
                            "port" = {
                              "description" = "Defines the health port."
                              "type"        = "integer"
                            }
                          }
                          "type" = "object"
                        }
                        "httpproxy" = {
                          "description" = "HTTPProxy defines parameters on HTTPProxy."
                          "properties" = {
                            "disablePermitInsecure" = {
                              "description" = <<-EOT
                              DisablePermitInsecure disables the use of the
                              permitInsecure field in HTTPProxy.
                              Contour's default is false.
                              EOT
                              "type"        = "boolean"
                            }
                            "fallbackCertificate" = {
                              "description" = <<-EOT
                              FallbackCertificate defines the namespace/name of the Kubernetes secret to
                              use as fallback when a non-SNI request is received.
                              EOT
                              "properties" = {
                                "name" = {
                                  "type" = "string"
                                }
                                "namespace" = {
                                  "type" = "string"
                                }
                              }
                              "required" = [
                                "name",
                                "namespace",
                              ]
                              "type" = "object"
                            }
                            "rootNamespaces" = {
                              "description" = "Restrict Contour to searching these namespaces for root ingress routes."
                              "items" = {
                                "type" = "string"
                              }
                              "type" = "array"
                            }
                          }
                          "type" = "object"
                        }
                        "ingress" = {
                          "description" = "Ingress contains parameters for ingress options."
                          "properties" = {
                            "classNames" = {
                              "description" = "Ingress Class Names Contour should use."
                              "items" = {
                                "type" = "string"
                              }
                              "type" = "array"
                            }
                            "statusAddress" = {
                              "description" = "Address to set in Ingress object status."
                              "type"        = "string"
                            }
                          }
                          "type" = "object"
                        }
                        "metrics" = {
                          "description" = <<-EOT
                          Metrics defines the endpoint Contour uses to serve metrics.
                          Contour's default is { address: "0.0.0.0", port: 8000 }.
                          EOT
                          "properties" = {
                            "address" = {
                              "description" = "Defines the metrics address interface."
                              "maxLength"   = 253
                              "minLength"   = 1
                              "type"        = "string"
                            }
                            "port" = {
                              "description" = "Defines the metrics port."
                              "type"        = "integer"
                            }
                            "tls" = {
                              "description" = <<-EOT
                              TLS holds TLS file config details.
                              Metrics and health endpoints cannot have same port number when metrics is served over HTTPS.
                              EOT
                              "properties" = {
                                "caFile" = {
                                  "description" = "CA filename."
                                  "type"        = "string"
                                }
                                "certFile" = {
                                  "description" = "Client certificate filename."
                                  "type"        = "string"
                                }
                                "keyFile" = {
                                  "description" = "Client key filename."
                                  "type"        = "string"
                                }
                              }
                              "type" = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "policy" = {
                          "description" = "Policy specifies default policy applied if not overridden by the user"
                          "properties" = {
                            "applyToIngress" = {
                              "description" = <<-EOT
                              ApplyToIngress determines if the Policies will apply to ingress objects
                              Contour's default is false.
                              EOT
                              "type"        = "boolean"
                            }
                            "requestHeaders" = {
                              "description" = "RequestHeadersPolicy defines the request headers set/removed on all routes"
                              "properties" = {
                                "remove" = {
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "type" = "array"
                                }
                                "set" = {
                                  "additionalProperties" = {
                                    "type" = "string"
                                  }
                                  "type" = "object"
                                }
                              }
                              "type" = "object"
                            }
                            "responseHeaders" = {
                              "description" = "ResponseHeadersPolicy defines the response headers set/removed on all routes"
                              "properties" = {
                                "remove" = {
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "type" = "array"
                                }
                                "set" = {
                                  "additionalProperties" = {
                                    "type" = "string"
                                  }
                                  "type" = "object"
                                }
                              }
                              "type" = "object"
                            }
                          }
                          "type" = "object"
                        }
                        "rateLimitService" = {
                          "description" = <<-EOT
                          RateLimitService optionally holds properties of the Rate Limit Service
                          to be used for global rate limiting.
                          EOT
                          "properties" = {
                            "defaultGlobalRateLimitPolicy" = {
                              "description" = <<-EOT
                              DefaultGlobalRateLimitPolicy allows setting a default global rate limit policy for every HTTPProxy.
                              HTTPProxy can overwrite this configuration.
                              EOT
                              "properties" = {
                                "descriptors" = {
                                  "description" = <<-EOT
                                  Descriptors defines the list of descriptors that will
                                  be generated and sent to the rate limit service. Each
                                  descriptor contains 1+ key-value pair entries.
                                  EOT
                                  "items" = {
                                    "description" = "RateLimitDescriptor defines a list of key-value pair generators."
                                    "properties" = {
                                      "entries" = {
                                        "description" = "Entries is the list of key-value pair generators."
                                        "items" = {
                                          "description" = <<-EOT
                                          RateLimitDescriptorEntry is a key-value pair generator. Exactly
                                          one field on this struct must be non-nil.
                                          EOT
                                          "properties" = {
                                            "genericKey" = {
                                              "description" = "GenericKey defines a descriptor entry with a static key and value."
                                              "properties" = {
                                                "key" = {
                                                  "description" = <<-EOT
                                                  Key defines the key of the descriptor entry. If not set, the
                                                  key is set to "generic_key".
                                                  EOT
                                                  "type"        = "string"
                                                }
                                                "value" = {
                                                  "description" = "Value defines the value of the descriptor entry."
                                                  "minLength"   = 1
                                                  "type"        = "string"
                                                }
                                              }
                                              "required" = [
                                                "value",
                                              ]
                                              "type" = "object"
                                            }
                                            "remoteAddress" = {
                                              "description" = <<-EOT
                                              RemoteAddress defines a descriptor entry with a key of "remote_address"
                                              and a value equal to the client's IP address (from x-forwarded-for).
                                              EOT
                                              "type"        = "object"
                                            }
                                            "requestHeader" = {
                                              "description" = <<-EOT
                                              RequestHeader defines a descriptor entry that's populated only if
                                              a given header is present on the request. The descriptor key is static,
                                              and the descriptor value is equal to the value of the header.
                                              EOT
                                              "properties" = {
                                                "descriptorKey" = {
                                                  "description" = "DescriptorKey defines the key to use on the descriptor entry."
                                                  "minLength"   = 1
                                                  "type"        = "string"
                                                }
                                                "headerName" = {
                                                  "description" = "HeaderName defines the name of the header to look for on the request."
                                                  "minLength"   = 1
                                                  "type"        = "string"
                                                }
                                              }
                                              "required" = [
                                                "descriptorKey",
                                                "headerName",
                                              ]
                                              "type" = "object"
                                            }
                                            "requestHeaderValueMatch" = {
                                              "description" = <<-EOT
                                              RequestHeaderValueMatch defines a descriptor entry that's populated
                                              if the request's headers match a set of 1+ match criteria. The
                                              descriptor key is "header_match", and the descriptor value is static.
                                              EOT
                                              "properties" = {
                                                "expectMatch" = {
                                                  "default"     = true
                                                  "description" = <<-EOT
                                                  ExpectMatch defines whether the request must positively match the match
                                                  criteria in order to generate a descriptor entry (i.e. true), or not
                                                  match the match criteria in order to generate a descriptor entry (i.e. false).
                                                  The default is true.
                                                  EOT
                                                  "type"        = "boolean"
                                                }
                                                "headers" = {
                                                  "description" = <<-EOT
                                                  Headers is a list of 1+ match criteria to apply against the request
                                                  to determine whether to populate the descriptor entry or not.
                                                  EOT
                                                  "items" = {
                                                    "description" = <<-EOT
                                                    HeaderMatchCondition specifies how to conditionally match against HTTP
                                                    headers. The Name field is required, only one of Present, NotPresent,
                                                    Contains, NotContains, Exact, NotExact and Regex can be set.
                                                    For negative matching rules only (e.g. NotContains or NotExact) you can set
                                                    TreatMissingAsEmpty.
                                                    IgnoreCase has no effect for Regex.
                                                    EOT
                                                    "properties" = {
                                                      "contains" = {
                                                        "description" = <<-EOT
                                                        Contains specifies a substring that must be present in
                                                        the header value.
                                                        EOT
                                                        "type"        = "string"
                                                      }
                                                      "exact" = {
                                                        "description" = "Exact specifies a string that the header value must be equal to."
                                                        "type"        = "string"
                                                      }
                                                      "ignoreCase" = {
                                                        "description" = <<-EOT
                                                        IgnoreCase specifies that string matching should be case insensitive.
                                                        Note that this has no effect on the Regex parameter.
                                                        EOT
                                                        "type"        = "boolean"
                                                      }
                                                      "name" = {
                                                        "description" = <<-EOT
                                                        Name is the name of the header to match against. Name is required.
                                                        Header names are case insensitive.
                                                        EOT
                                                        "type"        = "string"
                                                      }
                                                      "notcontains" = {
                                                        "description" = <<-EOT
                                                        NotContains specifies a substring that must not be present
                                                        in the header value.
                                                        EOT
                                                        "type"        = "string"
                                                      }
                                                      "notexact" = {
                                                        "description" = <<-EOT
                                                        NoExact specifies a string that the header value must not be
                                                        equal to. The condition is true if the header has any other value.
                                                        EOT
                                                        "type"        = "string"
                                                      }
                                                      "notpresent" = {
                                                        "description" = <<-EOT
                                                        NotPresent specifies that condition is true when the named header
                                                        is not present. Note that setting NotPresent to false does not
                                                        make the condition true if the named header is present.
                                                        EOT
                                                        "type"        = "boolean"
                                                      }
                                                      "present" = {
                                                        "description" = <<-EOT
                                                        Present specifies that condition is true when the named header
                                                        is present, regardless of its value. Note that setting Present
                                                        to false does not make the condition true if the named header
                                                        is absent.
                                                        EOT
                                                        "type"        = "boolean"
                                                      }
                                                      "regex" = {
                                                        "description" = <<-EOT
                                                        Regex specifies a regular expression pattern that must match the header
                                                        value.
                                                        EOT
                                                        "type"        = "string"
                                                      }
                                                      "treatMissingAsEmpty" = {
                                                        "description" = <<-EOT
                                                        TreatMissingAsEmpty specifies if the header match rule specified header
                                                        does not exist, this header value will be treated as empty. Defaults to false.
                                                        Unlike the underlying Envoy implementation this is **only** supported for
                                                        negative matches (e.g. NotContains, NotExact).
                                                        EOT
                                                        "type"        = "boolean"
                                                      }
                                                    }
                                                    "required" = [
                                                      "name",
                                                    ]
                                                    "type" = "object"
                                                  }
                                                  "minItems" = 1
                                                  "type"     = "array"
                                                }
                                                "value" = {
                                                  "description" = "Value defines the value of the descriptor entry."
                                                  "minLength"   = 1
                                                  "type"        = "string"
                                                }
                                              }
                                              "required" = [
                                                "value",
                                              ]
                                              "type" = "object"
                                            }
                                          }
                                          "type" = "object"
                                        }
                                        "minItems" = 1
                                        "type"     = "array"
                                      }
                                    }
                                    "required" = [
                                      "entries",
                                    ]
                                    "type" = "object"
                                  }
                                  "minItems" = 1
                                  "type"     = "array"
                                }
                                "disabled" = {
                                  "description" = <<-EOT
                                  Disabled configures the HTTPProxy to not use
                                  the default global rate limit policy defined by the Contour configuration.
                                  EOT
                                  "type"        = "boolean"
                                }
                              }
                              "type" = "object"
                            }
                            "domain" = {
                              "description" = "Domain is passed to the Rate Limit Service."
                              "type"        = "string"
                            }
                            "enableResourceExhaustedCode" = {
                              "description" = <<-EOT
                              EnableResourceExhaustedCode enables translating error code 429 to
                              grpc code RESOURCE_EXHAUSTED. When disabled it's translated to UNAVAILABLE
                              EOT
                              "type"        = "boolean"
                            }
                            "enableXRateLimitHeaders" = {
                              "description" = <<-EOT
                              EnableXRateLimitHeaders defines whether to include the X-RateLimit
                              headers X-RateLimit-Limit, X-RateLimit-Remaining, and X-RateLimit-Reset
                              (as defined by the IETF Internet-Draft linked below), on responses
                              to clients when the Rate Limit Service is consulted for a request.
                              ref. https://tools.ietf.org/id/draft-polli-ratelimit-headers-03.html
                              EOT
                              "type"        = "boolean"
                            }
                            "extensionService" = {
                              "description" = "ExtensionService identifies the extension service defining the RLS."
                              "properties" = {
                                "name" = {
                                  "type" = "string"
                                }
                                "namespace" = {
                                  "type" = "string"
                                }
                              }
                              "required" = [
                                "name",
                                "namespace",
                              ]
                              "type" = "object"
                            }
                            "failOpen" = {
                              "description" = <<-EOT
                              FailOpen defines whether to allow requests to proceed when the
                              Rate Limit Service fails to respond with a valid rate limit
                              decision within the timeout defined on the extension service.
                              EOT
                              "type"        = "boolean"
                            }
                          }
                          "required" = [
                            "extensionService",
                          ]
                          "type" = "object"
                        }
                        "tracing" = {
                          "description" = "Tracing defines properties for exporting trace data to OpenTelemetry."
                          "properties" = {
                            "customTags" = {
                              "description" = "CustomTags defines a list of custom tags with unique tag name."
                              "items" = {
                                "description" = <<-EOT
                                CustomTag defines custom tags with unique tag name
                                to create tags for the active span.
                                EOT
                                "properties" = {
                                  "literal" = {
                                    "description" = <<-EOT
                                    Literal is a static custom tag value.
                                    Precisely one of Literal, RequestHeaderName must be set.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "requestHeaderName" = {
                                    "description" = <<-EOT
                                    RequestHeaderName indicates which request header
                                    the label value is obtained from.
                                    Precisely one of Literal, RequestHeaderName must be set.
                                    EOT
                                    "type"        = "string"
                                  }
                                  "tagName" = {
                                    "description" = "TagName is the unique name of the custom tag."
                                    "type"        = "string"
                                  }
                                }
                                "required" = [
                                  "tagName",
                                ]
                                "type" = "object"
                              }
                              "type" = "array"
                            }
                            "extensionService" = {
                              "description" = "ExtensionService identifies the extension service defining the otel-collector."
                              "properties" = {
                                "name" = {
                                  "type" = "string"
                                }
                                "namespace" = {
                                  "type" = "string"
                                }
                              }
                              "required" = [
                                "name",
                                "namespace",
                              ]
                              "type" = "object"
                            }
                            "includePodDetail" = {
                              "description" = <<-EOT
                              IncludePodDetail defines a flag.
                              If it is true, contour will add the pod name and namespace to the span of the trace.
                              the default is true.
                              Note: The Envoy pods MUST have the HOSTNAME and CONTOUR_NAMESPACE environment variables set for this to work properly.
                              EOT
                              "type"        = "boolean"
                            }
                            "maxPathTagLength" = {
                              "description" = <<-EOT
                              MaxPathTagLength defines maximum length of the request path
                              to extract and include in the HttpUrl tag.
                              contour's default is 256.
                              EOT
                              "format"      = "int32"
                              "type"        = "integer"
                            }
                            "overallSampling" = {
                              "description" = <<-EOT
                              OverallSampling defines the sampling rate of trace data.
                              contour's default is 100.
                              EOT
                              "type"        = "string"
                            }
                            "serviceName" = {
                              "description" = <<-EOT
                              ServiceName defines the name for the service.
                              contour's default is contour.
                              EOT
                              "type"        = "string"
                            }
                          }
                          "required" = [
                            "extensionService",
                          ]
                          "type" = "object"
                        }
                        "xdsServer" = {
                          "description" = "XDSServer contains parameters for the xDS server."
                          "properties" = {
                            "address" = {
                              "description" = <<-EOT
                              Defines the xDS gRPC API address which Contour will serve.
                              Contour's default is "0.0.0.0".
                              EOT
                              "minLength"   = 1
                              "type"        = "string"
                            }
                            "port" = {
                              "description" = <<-EOT
                              Defines the xDS gRPC API port which Contour will serve.
                              Contour's default is 8001.
                              EOT
                              "type"        = "integer"
                            }
                            "tls" = {
                              "description" = <<-EOT
                              TLS holds TLS file config details.
                              Contour's default is { caFile: "/certs/ca.crt", certFile: "/certs/tls.cert", keyFile: "/certs/tls.key", insecure: false }.
                              EOT
                              "properties" = {
                                "caFile" = {
                                  "description" = "CA filename."
                                  "type"        = "string"
                                }
                                "certFile" = {
                                  "description" = "Client certificate filename."
                                  "type"        = "string"
                                }
                                "insecure" = {
                                  "description" = "Allow serving the xDS gRPC API without TLS."
                                  "type"        = "boolean"
                                }
                                "keyFile" = {
                                  "description" = "Client key filename."
                                  "type"        = "string"
                                }
                              }
                              "type" = "object"
                            }
                          }
                          "type" = "object"
                        }
                      }
                      "type" = "object"
                    }
                  }
                  "type" = "object"
                }
                "status" = {
                  "description" = "ContourDeploymentStatus defines the observed state of a ContourDeployment resource."
                  "properties" = {
                    "conditions" = {
                      "description" = "Conditions describe the current conditions of the ContourDeployment resource."
                      "items" = {
                        "description" = "Condition contains details for one aspect of the current state of this API Resource."
                        "properties" = {
                          "lastTransitionTime" = {
                            "description" = <<-EOT
                            lastTransitionTime is the last time the condition transitioned from one status to another.
                            This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                            EOT
                            "format"      = "date-time"
                            "type"        = "string"
                          }
                          "message" = {
                            "description" = <<-EOT
                            message is a human readable message indicating details about the transition.
                            This may be an empty string.
                            EOT
                            "maxLength"   = 32768
                            "type"        = "string"
                          }
                          "observedGeneration" = {
                            "description" = <<-EOT
                            observedGeneration represents the .metadata.generation that the condition was set based upon.
                            For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date
                            with respect to the current state of the instance.
                            EOT
                            "format"      = "int64"
                            "minimum"     = 0
                            "type"        = "integer"
                          }
                          "reason" = {
                            "description" = <<-EOT
                            reason contains a programmatic identifier indicating the reason for the condition's last transition.
                            Producers of specific condition types may define expected values and meanings for this field,
                            and whether the values are considered a guaranteed API.
                            The value should be a CamelCase string.
                            This field may not be empty.
                            EOT
                            "maxLength"   = 1024
                            "minLength"   = 1
                            "pattern"     = "^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$"
                            "type"        = "string"
                          }
                          "status" = {
                            "description" = "status of the condition, one of True, False, Unknown."
                            "enum" = [
                              "True",
                              "False",
                              "Unknown",
                            ]
                            "type" = "string"
                          }
                          "type" = {
                            "description" = "type of condition in CamelCase or in foo.example.com/CamelCase."
                            "maxLength"   = 316
                            "pattern"     = "^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$"
                            "type"        = "string"
                          }
                        }
                        "required" = [
                          "lastTransitionTime",
                          "message",
                          "reason",
                          "status",
                          "type",
                        ]
                        "type" = "object"
                      }
                      "type" = "array"
                      "x-kubernetes-list-map-keys" = [
                        "type",
                      ]
                      "x-kubernetes-list-type" = "map"
                    }
                  }
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served"  = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}
