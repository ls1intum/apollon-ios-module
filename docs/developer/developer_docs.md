# Apollon iOS Module Developer Docs

## Overview

- **ApollonShared**: Contains all data models used by Apollon
- **ApollonRenderer**: Contains all the rendering logic
- **ApollonEdit**: Allows for the editing of UML diagrams
- **ApollonView**: Allows for the viewing of UML diagrams 

## Architecture

![Subsystem decomposition of the Apollon-iOS-Module](./images/subsystem_decomposition.png)

*Figure: Subsystem decomposition of the `Apollon-iOS-Module`.*

## Usage

### ApollonEdit
```swift
import ApollonEdit

ApollonEdit(umlModel: Binding<UMLModel>,
            diagramType: UMLDiagramType,
            fontSize: CGFloat,
            themeColor: Color,
            diagramOffset: CGPoint,
            isGridBackground: Bool)
```

### ApollonView
```swift
import ApollonView

ApollonView(umlModel: UMLModel,
            diagramType: UMLDiagramType,
            fontSize: CGFloat,
            themeColor: Color,
            diagramOffset: CGPoint,
            isGridBackground: Bool,
            @ViewBuilder content: () -> Content)
```

## Adding a New Diagram Type

In this section, we will look at how you can add a new diagram type. For this, we will go through each module of the package and discuss what needs to be added.

### `ApollonView`

In this module, nothing has to be added or changed in regard to adding a new diagram type.

### `ApollonShared`

In this module, we focus on the Data and DataModels.

- `DataModels/Types/UMLElementType.swift`: 
    1. Add all the different element types as cases to the `UMLElementType` enum, that your new diagram type can use. 
    2. Go through the other variables, to see if any apply to your new elements.
    
- `DataModels/Types/UMLRelationshipType.swift`: 
    1. Add all the different relationship types as cases to the `UMLRelationshipType` enum, that your new diagram type can use.
    
- `DataModels/Types/UMLDiagramType.swift`: 
    1. Add a new case to the `UMLDiagramType` enum with the name of your new diagram type. 
    2. Add a new case to the `diagramElementTypes` variable with your diagram type name and return the applicable element types.
    3. Add a new case to the `diagramRelationshipTypes` variable with your diagram type name and return the applicable relationship types.
    4. Add your diagram type to the `isDiagramTypeUnsupported()` function, as a false case, to enable the use of the diagram type (It is recommended to do this step after finishing all other steps that follow, as completing this step will make the diagram 'go live').
    
- Get familiar with all the other DataModels and adjust them only if needed. If adjusting, please make sure to adhere to the Apollon data format.

### `ApollonRenderer`

In this module, we focus on the rendering of the new diagram type

- `DiagramRenderers`: 
    1. Create a new folder in this directory and name it after your diagram type.
    
- `DiagramRenderers/<DiagramType>`:
    1. Create 3 new files in this directory and name them `<DiagramType>Renderer.swift`, `<DiagramType>ElementRenderer.swift` and `<DiagramType>RelationshipRenderer.swift`.

- `DiagramRenderers/<DiagramType>/<DiagramType>ElementRenderer.swift`:
    1. Create a struct named after the file name that extends the `UMLDiagramRenderer`.
    2. Create a public `render(umlModel: UMLModel)` function, that initiates the element rendering process.
    3. Follow the structure of other diagram types element rendering process and create your specific element rendering process.

- `DiagramRenderers/<DiagramType>/<DiagramType>RelationshipRenderer.swift`:
    1. Create a struct named after the file name that extends the `UMLDiagramRenderer`.
    2. Create a public `render(umlModel: UMLModel)` function, that initiates the relationship rendering process.
    3. Follow the structure of other diagram types relationship rendering process and create your specific relationship rendering process.
    
- `DiagramRenderers/<DiagramType>/<DiagramType>Renderer.swift`:
    1. Add the following code and change the <DiagramType> placeholder:
    ```swift
    import SwiftUI
    import ApollonShared

    struct <DiagramType>Renderer: UMLDiagramRenderer {
        var context: UMLGraphicsContext
        let canvasBounds: CGRect
        var fontSize: CGFloat = 14
    
        func render(umlModel: UMLModel) {
            let elementRenderer = <DiagramType>ElementRenderer(context: context,
                                                                canvasBounds: canvasBounds,
                                                                fontSize: fontSize)
            let relationshipRenderer = <DiagramType>RelationshipRenderer(context: context,
                                                                       canvasBounds: canvasBounds,
                                                                       fontSize: fontSize)
            elementRenderer.render(umlModel: umlModel)
            relationshipRenderer.render(umlModel: umlModel)
        }
    }
    ```

- `DiagramRenderers/UMLDiagramRenderer.swift`:
    1. Add your <DiagramType> as a case to the `UMLDiagramRendererFactory` enum and return your `<DiagramType>Renderer` struct.

### `ApollonEdit`

In this module, we focus on the editing and interaction of the new diagram type and its elements and relationships.

- `Resources/Assets/ElementIcons`:
    1. Create a folder and name it after your <DiagramType>.
    2. Add all the images of your elements to this folder and name them exactly how you did in the `UMLElementType.swift` file. These images are shown to a user that would like to add a new element to the canvas. 

- `Views/CreateElement/ElementCreator.swift`:
    1. Create a new struct in this file and name it `<ElementType>Creator` for each element type you want to add. Make sure each struct implements the `ElementCreator` protocol.
    2. Add a function to each struct called `createAllElements(for type: UMLElementType, middle: CGPoint)` (use the other `ElementCreator`s as a guide) that returns an array of `UMLElement`s.
    3. Add a case to the `ElementCreatorFactory` enum with each new element and return the specific `ElementCreator` you just created.

- `Views/Edit/EditElement/DiagramElementEditViews`:
    1. Create a new file called `<DiagramType>ElementEditView.swift`.

- `Views/Edit/EditElement/DiagramElementEditViews/<DiagramType>ElementEditView.swift`:
    1. Create a new view struct that is named after the file.
    2. In the body of this `View`, create a view that a user should see when editing an element. (Have a look at other element editing view files for inspiration and use the `CommonEditViews.swift` file for some predefined and common editing views)

- `Views/Edit/EditElement/ElementEditPopUpView.swift`:
    1. In the body of the `ElementEditPopUpView` struct, add a new else if statement that checks if the diagram type equals your new diagram type. If so, display your newly created `<DiagramType>ElementEditView()` view.

- `Views/Edit/EditRelationship/DiagramRelationshipEditViews`:
    1. Create a new file called `<DiagramType>RelationshipEditView.swift`.

- `Views/Edit/EditRelationship/DiagramRelationshipEditViews/<DiagramType>RelationshipEditView.swift`:
    1. Create a new view struct that is named after the file.
    2. In the body of this `View`, create a view that a user should see when editing a relationship. (Have a look at other relationship editing view files for inspiration and use the `CommonEditViews.swift` file for some predefined and common editing views)

- `Views/Edit/EditRelationship/RelationshipEditPopUpView.swift`:
    1. In the body of the `RelationshipEditPopUpView` struct, add a new else if statement that checks if the diagram type equals your new diagram type. If so, display your newly created `<DiagramType>RelationshipEditView()` view.



