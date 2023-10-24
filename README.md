![][1]

# AML-UA-XSLT
The AML-UA-XSLT contains XSL transformation rules (XSLT 2.0) which convert either AutomationML models to OPC UA XML nodeset descriptions or vice versa. The transformation rules are created according to the OPC UA companion specification „AutomationML for OPC UA“. The xslt files can be used in combination with standard XSLT processors which are not part of AML-UA-XSLT.

To use it, just take the XSLT files, use a standard XSLT processor and apply either
- AML2Nodeset.xslt to an AutomationML or
- Nodeset2AML.xslt to an OPC UA file.
Be careful, the other XSLTs in the repository are linked within these top-level transformations, i.e. they are necessary, too.

The project is work in progress and contains the current status of the work of the joint working group of AutomationML and OPC UA.

[1]: https://raw.githubusercontent.com/AutomationML/AMLEngine2.1/master/img/AutomationML-Logo.png
