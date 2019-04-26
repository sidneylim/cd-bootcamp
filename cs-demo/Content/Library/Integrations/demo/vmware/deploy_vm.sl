namespace: Integrations.demo.vmware
flow:
  name: deploy_vm
  inputs:
    - host: "${get_sp('vcenter_host')}"
    - user: "${get_sp('vcenter_user')}"
    - password: "${get_sp('vcenter_password')}"
    - image: "${get_sp('vcenter_image')}"
    - datacenter: "${get_sp('vcenter_datacenter')}"
    - folder: "${get_sp('vcenter_folder')}"
    - prefix: sid-
  workflow:
    - unique_vm_name_generator:
        do:
          io.cloudslang.vmware.vcenter.util.unique_vm_name_generator:
            - vm_name_prefix: '${prefix}'
        publish:
          - vm_name
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: on_failure
    - clone_vm:
        do:
          io.cloudslang.vmware.vcenter.vm.clone_vm:
            - host: '${host}'
            - user: '${user}'
            - password:
                value: '${password}'
                sensitive: true
            - vm_source_identifier: name
            - vm_source: '${image}'
            - datacenter: '${datacenter}'
            - vm_name: '${vm_name}'
            - vm_folder: '${folder}'
            - mark_as_template: 'false'
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - vm_id
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: on_failure
    - power_on_vm:
        do:
          io.cloudslang.vmware.vcenter.power_on_vm:
            - host: '${host}'
            - user: '${user}'
            - password:
                value: '${password}'
                sensitive: true
            - vm_identifier: name
            - vm_name: '${vm_name}'
            - datacenter: '${datacenter}'
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: on_failure
    - wait_for_vm_info:
        do:
          io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
            - host: '${host}'
            - user: '${user}'
            - password:
                value: '${password}'
                sensitive: true
            - vm_identifier: name
            - vm_name: '${vm_name}'
            - datacenter: '${datacenter}'
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
        publish:
          - ip
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - vm_name: '${vm_name}'
    - ip: '${ip}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      unique_vm_name_generator:
        x: 114
        y: 142
      clone_vm:
        x: 357
        y: 136
      power_on_vm:
        x: 118
        y: 327
      wait_for_vm_info:
        x: 384
        y: 317
        navigate:
          92720101-8057-5e55-6de8-a0e2c366b22f:
            targetId: 5545e619-c2d7-a39a-2a8f-c349eb50e55c
            port: SUCCESS
    results:
      SUCCESS:
        5545e619-c2d7-a39a-2a8f-c349eb50e55c:
          x: 533
          y: 179
