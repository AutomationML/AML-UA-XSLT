![][1]

# AML-UA-XSLT
The AML-UA-XSLT contains XSL transformation rules (XSLT 2.0) which convert either AutomationML models to OPC UA XML nodeset descriptions or vice versa. The transformation rules are created according to the OPC UA companion specification „AutomationML for OPC UA“. The xslt files can be used in combination with standard XSLT processors which are not part of AML-UA-XSLT.

To use it, just take the XSLT files, use a standard XSLT processor and apply either
- AML2Nodeset.xslt to an AutomationML (to transform it to OPC UA information model) or
- Nodeset2AML.xslt to an OPC UA file (to transform it to AML model).
Be careful, the other XSLTs in the repository are linked within these top-level transformations, i.e. they are necessary, too.

Additionally, in the folder UnitTests, there are test files for each AutomationML aspect:

| Element | AutomationML | OPC UA | Content |
|---|---|---|---|
| T00 | 0_EmptyFile_V2.0.aml |  | CAEX 2.15 empty |
| T00 | 0_EmptyFile_V2.1.aml |  | CAEX 3 empty |
| T01 | 1_AMLBaseLibraries.aml | 1_AML_Base_Libraries.xml | All AutomationML standard base libraries |
| T02 | 2_IE.aml | 2_IE.xml | A AML InternalElement with child element |
| T03 | 3_IE_Attribute.aml | 3_IE_Attribute.xml | A AML InternalElement with child element and attribute |
| T04 | 4_IH.aml | 4_IH.xml | An InstanceHierarchy with an InternalElement |
| T05 | 5_SUC.aml | 5_SUC.xml | An AML   SystemUnitClass with Internalelement and attribute.      An InstanceHierarchy which includes an InternalElement which references the   SUC. |
| T06 | 6_RCL.aml | 6_RCL.xml | An AML Roleclass with child element and attribute |
| T07 | 7_ICL.aml | 7_ICL.xml | An AML InterfaceClass with child element and attribute |
| T08 | 8_AMLAttributeLibrary.aml | 8_AMLAttributeLibrary.xml | An AttributeTypeLibrary with AttributeTypes which are derived   from each other and an InstanceHierarchy with Attributes which are derived   from an AttributeType |
| T09 | 9_ExtInt_IntLink.aml | 9_ExtInt_IntLink.xml | An InstanceHierarchy   with ExternalInterfaces, InternalLinks and   RoleRequirements/SupportedRoleClass, RefBase SystemUnit.      A SystemUnitLibrary with SupportedRoleClass andExternalInterface      A RoleClass with ExternalReference/Alias      An InterfaceClass with ExternalReference/Alias |
| T10 | 10_RefSemantic.aml | 10_RefSemantic.xml | RefSemantik with reference to external semantics |
| T11 | 11_Constraints.aml | 11_Constraints.xml | Attribute with constraints of different type |
| T12 | 12_MirrorObject.aml | 12_MirrorObject.xml | InternalElement with relation to Master Object |
| T13 | 13_Facet.aml | 13_Facet.xml | Facet Attribute (Noise in Parent and Child InternalElement |

The project is work in progress and contains the current status of the work of the joint working group of AutomationML and OPC UA. 
It is a newer version of the published companion spec rules: https://opcfoundation.org/developer-tools/documents/view/276.

[1]: https://raw.githubusercontent.com/AutomationML/AMLEngine2.1/master/img/AutomationML-Logo.png
