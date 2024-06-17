## We've added this labels so they are recongnized by the Kubernetes plugin 
```yaml
labels:
    backstage.io/kubernetes-id: my-app-frontend
```

## We've accomodated the directory structure to more appropiately fit the new 
meme-web (used to be my-app) helm charts now exists within [/helm-charts/systems/ dir](/helm-charts/systems/) because now we have the possibility of other syetems existing.
So my-app is a sytem whinch includes my-app frontend  and my-app-backend but we could also have your-app system which might include any number of services.

## Flagger limitation
Backstage Kubernetes plugin can't display information from the primary deployments pods because we can't assign labels to the primary deploymeny through the Fagger canary. Backstage needs the ```backstage.io/kubernetes-id``` to recognize and display the resource in the UI.

We would require [this functionality](https://docs.flagger.app/usage/how-it-works#canary-service) but for deployments instead of services.

See https://github.com/fluxcd/flagger/issues/1115#issuecomment-1631266845.


## ui:options Examples
```yaml
        ##############################
        # Array with custom titles
        region:
          title: Region
          type: string
          description: In what AWS region will the EKS cluster be deployed.
          default: us-east-1
          enum:
            - us-east-1
            - us-east-2
            - us-west-1
            - us-west-2
          enumNames:
            - 'Virginia (us-east-1)'
            - 'Ohio (us-east-2)'
            - 'California (us-west-1)'
            - 'Oregon (us-west-2)'

        ##############################
        # Multiple choice list
        multichoice:
          title: Select environments
          type: array
          items:
            type: string
            enum:
              - production
              - staging
              - development
          uniqueItems: true
          ui:widget: checkboxes

        ##############################
        # Boolean
        boolean:
          title: Checkbox boolean
          type: boolean

        ##############################
        # Boolean with radio
        flag:
          title: Yes or No options
          type: boolean
          ui:widget: radio

        ##############################
        # Boolean with multiple optiones
        name:
          title: Select features
          type: array
          items:
            type: boolean
            enum:
              - 'Enable scraping'
              - 'Enable HPA'
              - 'Enable cache'
          uniqueItems: true
          ui:widget: checkboxes

        ##############################
        # Multi line text input
        multiline:
          title: Text area input
          type: string
          description: Insert your multi line string
          ui:widget: textarea
          ui:options:
            rows: 10
          ui:help: 'Hint: Make it strong!'
          ui:placeholder: |
            apiVersion: backstage.io/v1alpha1
              kind: Component
              metadata:
                name: backstage
              spec:
                type: library
                owner: CNCF
                lifecycle: experimental

        ##############################
        # Array with another types
        arrayObjects:
          title: Array with custom objects
          type: array
          minItems: 0
          ui:options:
            addable: true
            orderable: true
            removable: true
          items:
            type: object
            properties:
              array:
                title: Array string with default value
                type: string
                default: value3
                enum:
                  - value1
                  - value2
                  - value3
              flag:
                title: Boolean flag
                type: boolean
                ui:widget: radio
              someInput:
                title: Simple text input
                type: string
```
[Source](https://backstage.io/docs/features/software-templates/ui-options-examples/)

<!-- Writing scaffolder templates
https://backstage.io/docs/features/software-templates/ui-options-examples/

Input Examples
https://backstage.io/docs/features/software-templates/input-examples -->