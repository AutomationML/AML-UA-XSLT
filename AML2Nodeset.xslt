<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" 
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xsi:noNamespaceSchemaLocation="CAEX_ClassModel_V2.15.xsd" 
		exclude-result-prefixes="#default xsi xsl exslt fn"
		xmlns:exslt="http://exslt.org/common">
		
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
		
	<xsl:function name="exslt:node-set">
		<xsl:param name="rtf"/>
		<xsl:sequence select="$rtf"/>
	</xsl:function>
	
	<!-- Parsing of SystemUnitClassLib, InterfaceClassLib, RoleClassLib-->
	<xsl:include href="LibraryParsing.xslt"/>
	<xsl:include href="DatatypeTranslation.xslt"/>
	<!-- Translation of SystemUnitClassLib, InterfaceClassLib, RoleClassLib-->
	<xsl:include href="LibraryTranslation.xslt"/>
	
	
<!-- ************************************************************************
***  
***  Skeleton
***
****************************************************************************** -->
	<!-- .........................................................................
		CAEXFile: Create Skeleton
	.........................................................................-->
	<xsl:template match="CAEXFile">
		<UANodeSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd">
			<xsl:comment>
			UANodeSet
			=============
			TODOs:
				- What is the representation of CAEXFile?
				- How to handle multiple AdditionalInformation
					    use first ElementName (or AttributeName) as BrowseName/ID/DisplayName
						define specific SystemUnitClass or RoleClass						
				- Do we need aliases??
				- What shall we do with the WriterHeader?
				- Are such simple namespaces allowed? How to use them in the NodeId attribute?
				- How to name the local instance namespace? And should we always use it as second ns -> can use ns=2 and the user can change the ns in the URI list?
				- InternalLinks are not translated, yet.
				- Missing translation for UtcTime/DateTime
				- How to use Table 14 in DataTypeMapping v5.0? -> Add mapping to translation table
		</xsl:comment>
			<NamespaceUris>
				<Uri>http://opcfoundation.org/UA/AML/</Uri>
				<Uri>MyInstances</Uri>
				<xsl:for-each select="InterfaceClassLib">
					<Uri>
						<xsl:value-of select="@Name"/>
					</Uri>
				</xsl:for-each>
				<xsl:for-each select="RoleClassLib">
					<Uri>
						<xsl:value-of select="@Name"/>
					</Uri>
				</xsl:for-each>
				<xsl:for-each select="SystemUnitClassLib">
					<Uri>
						<xsl:value-of select="@Name"/>
					</Uri>
				</xsl:for-each>
			</NamespaceUris>
		  <Aliases>
			<Alias Alias="Boolean">i=1</Alias>
			<Alias Alias="SByte">i=2</Alias>
			<Alias Alias="Byte">i=3</Alias>
			<Alias Alias="Int16">i=4</Alias>
			<Alias Alias="UInt16">i=5</Alias>
			<Alias Alias="Int32">i=6</Alias>
			<Alias Alias="UInt32">i=7</Alias>
			<Alias Alias="Int64">i=8</Alias>
			<Alias Alias="UInt64">i=9</Alias>
			<Alias Alias="Float">i=10</Alias>
			<Alias Alias="Double">i=11</Alias>
			<Alias Alias="DateTime">i=13</Alias>
			<Alias Alias="String">i=12</Alias>
			<Alias Alias="ByteString">i=15</Alias>
			<Alias Alias="Guid">i=14</Alias>
			<Alias Alias="XmlElement">i=16</Alias>
			<Alias Alias="NodeId">i=17</Alias>
			<Alias Alias="LocalizedText">i=21</Alias>
			<Alias Alias="Structure">i=22</Alias>
			<Alias Alias="Number">i=26</Alias>
			<Alias Alias="Integer">i=27</Alias>
			<Alias Alias="UInteger">i=28</Alias>
			<Alias Alias="HasComponent">i=47</Alias>
			<Alias Alias="HasProperty">i=46</Alias>
			<Alias Alias="PropertyType">i=68</Alias>
		  </Aliases>
			<xsl:apply-templates select="node()"/>
		</UANodeSet>
	</xsl:template>
	<!-- .........................................................................
		WriterHeader: Ignore
	.........................................................................-->
	<xsl:template match="CAEXFile/AdditionalInformation/WriterHeader"/>
	<!-- .........................................................................
		InstanceHierarchy: Create UAObjecs
	.........................................................................-->
	<xsl:template match="InstanceHierarchy">
		<xsl:comment>
			InstanceHierarchy
			=============
			TODOs:
			    - Complete References
				- Do we need BackwardReferences here?
				- Test child of AutomationMLBaseRole/UABaseObjectType
				- currently only type definition from Libraries are supported -> support HasTypeDefinition from current namespace
		</xsl:comment>
		<xsl:apply-templates select="node()"/>
	</xsl:template>

<!-- ************************************************************************
***  
***  Attributes
***
****************************************************************************** -->
	<!-- .........................................................................
		Specific attributes of InternalElements and Class definitions
	.........................................................................-->
	<xsl:template name="StringAttributeVariable">
		<xsl:param name="ObjectName"/>
		<xsl:param name="ParentId"/>
		<xsl:param name="Namespace"/>
		<xsl:param name="AttributeName"/>
		<xsl:param name="AttributeValue"/>
		<!-- Create property -->
		<xsl:comment><xsl:text>Attribute: </xsl:text><xsl:value-of select="$ObjectName"/>.<xsl:value-of select="$AttributeName"/></xsl:comment>
		<UAVariable>
			<xsl:attribute name="NodeId"><xsl:value-of select="$Namespace"/>;<xsl:value-of select="$ParentId"/>_<xsl:value-of select="$AttributeName"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="$AttributeName"/></xsl:attribute>
			<xsl:attribute name="ParentNodeId"><xsl:value-of select="$Namespace"/>;<xsl:value-of select="$ParentId"/></xsl:attribute>
			<xsl:attribute name="DataType">String</xsl:attribute>
			<DisplayName><xsl:value-of select="$AttributeName"/></DisplayName>
			<References>
				<Reference ReferenceType="HasTypeDefinition">i=68</Reference>
			</References>
			<Value>
				<String xmlns="http://opcfoundation.org/UA/2008/02/Types.xsd">
					<xsl:copy-of select="$AttributeValue"/>
				</String>
			</Value>
		</UAVariable>
	</xsl:template>
	<xsl:template match="@ID">
		<!-- Create AML-ID property -->
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName" select="../@Name"/>
			<xsl:with-param name="ParentId" select="concat('g={', ../@ID, '}')"/>
			<xsl:with-param name="Namespace" select="'ns=2'"/>
			<xsl:with-param name="AttributeName" select="'ID'"/>
			<xsl:with-param name="AttributeValue" select="concat('{', ../@ID, '}')"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="Version">
		<xsl:choose>
			<xsl:when test="local-name(..)='InterfaceClassLib' or local-name(..)='RoleClassLib' or local-name(..)='SystemUnitClassLib'">
				<xsl:call-template name="StringAttributeVariable">
					<xsl:with-param name="ObjectName" select="../@Name"/>
					<xsl:with-param name="ParentId" select="'s=Library'"/>
					<xsl:with-param name="Namespace" select="concat('ns=', ../@Name)"/>
					<xsl:with-param name="AttributeName" select="'Version'"/>
					<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="StringAttributeVariable">
					<xsl:with-param name="ObjectName" select="../@Name"/>
					<xsl:with-param name="ParentId" select="concat('g={', ../@ID, '}')"/>
					<xsl:with-param name="Namespace" select="'ns=2'"/>
					<xsl:with-param name="AttributeName" select="'Version'"/>
					<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--xsl:template match="Revision"></xsl:template-->
	<xsl:template match="Copyright">
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName" select="../@Name"/>
			<xsl:with-param name="ParentId" select="concat('g={', ../@ID, '}')"/>
			<xsl:with-param name="Namespace" select="'ns=2'"/>
			<xsl:with-param name="AttributeName" select="'Copyright'"/>
			<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="*[name()!='CAEXFile']/AdditionalInformation">
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName" select="../@Name"/>
			<xsl:with-param name="ParentId" select="concat('g={', ../@ID, '}')"/>
			<xsl:with-param name="Namespace" select="'ns=2'"/>
			<xsl:with-param name="AttributeName" select="'AdditionalInformation'"/>
			<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
		</xsl:call-template>	
	</xsl:template>
	<xsl:template match="CAEXFile/AdditionalInformation">
		<xsl:comment>Version 1:</xsl:comment>
		<xsl:variable name="AttributeName">
			<_attrName>
			<xsl:choose>
				<xsl:when test="name(*[1])!=''"><xsl:value-of select="name(*[1])"/></xsl:when>
				<xsl:when test="name(@*[1])!=''"><xsl:value-of select="name(@*[1])"/></xsl:when>
				<xsl:otherwise>AdditionalInformation</xsl:otherwise>
			</xsl:choose>
			</_attrName>
		</xsl:variable>	


		<!-- Create property -->
		<xsl:comment><xsl:text>Attribute: </xsl:text>CAEXFile.<xsl:value-of select="$AttributeName"/></xsl:comment>
		<UAVariable>
			<xsl:attribute name="NodeId">ns=2;s=CAEXFile_<xsl:value-of select="$AttributeName"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="$AttributeName"/></xsl:attribute>
			<xsl:attribute name="ParentNodeId">ns=2;s=CAEXFile</xsl:attribute>
			<xsl:attribute name="DataType">String</xsl:attribute>
			<DisplayName><xsl:value-of select="$AttributeName"/></DisplayName>
			<References>
				<Reference ReferenceType="HasTypeDefinition">ns=1;s=AdditionalInformation</Reference>
			</References>
			<Value>
				<String xmlns="http://opcfoundation.org/UA/2008/02/Types.xsd">
					<xsl:copy-of select="."/>
				</String>
			</Value>
		</UAVariable>

		<xsl:comment>Version 2:</xsl:comment>
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName">CAEXFile</xsl:with-param>
			<xsl:with-param name="ParentId">s=CAEXFile</xsl:with-param>
			<xsl:with-param name="Namespace">ns=2</xsl:with-param>
			<xsl:with-param name="AttributeName">AdditionalInformation</xsl:with-param>
			<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
		</xsl:call-template>	
	</xsl:template>
	<xsl:template match="CAEXFile/FileName">
		<xsl:comment>TODO: For a better usability of the CAEXFile.FileName it is recommended to use it as part of the BrowseName. </xsl:comment>
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName"><xsl:value-of select="../@Name"/></xsl:with-param>
			<xsl:with-param name="ParentId">s=CAEXFile</xsl:with-param>
			<xsl:with-param name="Namespace">ns=2</xsl:with-param>
			<xsl:with-param name="AttributeName">FileName</xsl:with-param>
			<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
		</xsl:call-template>	

	</xsl:template>
	<xsl:template match="CAEXFile/SchemaVersion">
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName"><xsl:value-of select="../@Name"/></xsl:with-param>
			<xsl:with-param name="ParentId">s=CAEXFile</xsl:with-param>
			<xsl:with-param name="Namespace">ns=2</xsl:with-param>
			<xsl:with-param name="AttributeName">SchemaVersion</xsl:with-param>
			<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
		</xsl:call-template>	

	</xsl:template>

	<!-- .........................................................................
		Attribute tags of InternalElements and Class definitions
	.........................................................................-->
	<xsl:template match="Attribute">
		<!-- Get object variables -->
		<xsl:variable name="ObjectId">
			<xsl:choose>
				<xsl:when test="../@ID!=''">{<xsl:value-of select="../@ID"/>}</xsl:when>
				<xsl:otherwise><xsl:value-of select="../@Name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="ObjectNodeId">
			<xsl:choose>
				<xsl:when test="../@ID!=''">g=<xsl:value-of select="$ObjectId"/></xsl:when>
				<xsl:otherwise>s=<xsl:value-of select="$ObjectId"/></xsl:otherwise>
			</xsl:choose>		
		</xsl:variable>
		<xsl:variable name="AttributeDataType"><xsl:value-of select="@AttributeDataType"/></xsl:variable>
		<xsl:comment>
			<xsl:text>Attribute: </xsl:text>
			<xsl:value-of select="../@Name"/>.<xsl:value-of select="@Name"/>
		</xsl:comment>
		<UAVariable>
			<xsl:attribute name="NodeId">ns=2;s=<xsl:value-of select="$ObjectId"/>_<xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="ParentNodeId">ns=2;<xsl:value-of select="$ObjectNodeId"/></xsl:attribute>
			<xsl:attribute name="DataType">
				<xsl:choose>
					<xsl:when test="exslt:node-set($DataTypes)/*[@AML=$AttributeDataType]/@OPC!=''">
						<xsl:value-of select="exslt:node-set($DataTypes)/*[@AML=$AttributeDataType]/@OPC"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-after($AttributeDataType, ':')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:comment>TODO: correct TypeDefinition</xsl:comment>
			<References>
				<Reference ReferenceType="HasTypeDefinition">i=68</Reference>
			</References>
			<Value>
				<xsl:value-of select="Value"/>
			</Value>
		</UAVariable>
	</xsl:template>
	<!-- .........................................................................
		References to all kind of attributes
	.........................................................................-->
	<xsl:template name="References">
		<xsl:param name="ObjectName"/>
		<xsl:param name="ObjectId"/>
		<!-- Reference to AML-ID property -->
		<xsl:comment>AML-ID</xsl:comment>
		<Reference ReferenceType="HasProperty">ns=2;s={<xsl:value-of select="$ObjectId"/>}_ID</Reference>
		<!-- Reference to Version property -->
		<xsl:if test="Version">
			<xsl:comment>Version</xsl:comment>
			<Reference ReferenceType="HasProperty">ns=2;s={<xsl:value-of select="$ObjectId"/>}_Version</Reference>
		</xsl:if>
		<!-- References for all Attribute properties -->
		<xsl:for-each select="Attribute">
			<xsl:comment>
				<xsl:text>Attribute: </xsl:text>
				<xsl:value-of select="@Name"/>
			</xsl:comment>
			<Reference ReferenceType="HasProperty">ns=2;s={<xsl:value-of select="$ObjectId"/>}_<xsl:value-of select="@Name"/>
			</Reference>
		</xsl:for-each>
		<!-- Reference to SupportedRoleClass -->
		<xsl:for-each select="SupportedRoleClass">
			<!-- Parse SupportedRoleClass -->
			<xsl:variable name="RCName" select="substring-before(@RefRoleClassPath,'/')"/>
			<xsl:variable name="RCContent">
				<xsl:if test="$RCName!= '' and $RCName!= 'AutomationMLBaseRoleClassLib/AutomationMLBaseRole'">
					<xsl:call-template name="GetClass">
						<xsl:with-param name="path" select="@RefRoleClassPath"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>
			<xsl:variable name="LibName" select="ancestor::RoleClassLib[1]/@Name"/>
			<!-- Create HasAMLRoleReference -->
			<xsl:comment>
				<xsl:text>SupportedRoleClass: </xsl:text>
				<xsl:value-of select="@RefRoleClassPath"/>
			</xsl:comment>
			
			<Reference ReferenceType="HasAMLRoleReference">
				<xsl:value-of select="concat('ns=', $RCName, ';s=', exslt:node-set($RCContent)/RoleClass/@Name)"/>				
			</Reference>
		</xsl:for-each>
		<!-- Reference to ExternalInterface objects -->
		<xsl:for-each select="ExternalInterface">
			<xsl:comment>
				<xsl:text>ExternalInterface: </xsl:text>
				<xsl:value-of select="@Name"/>
			</xsl:comment>
			<Reference ReferenceType="HasComponent">ns=2;s={<xsl:value-of select="$ObjectId"/>}_<xsl:value-of select="@Name"/>
			</Reference>
		</xsl:for-each>
		<!-- Reference to InternalElement objects -->
		<xsl:for-each select="InternalElement">
			<xsl:comment>
				<xsl:text>InternalElement: </xsl:text>
				<xsl:value-of select="@Name"/>
			</xsl:comment>
			<Reference ReferenceType="HasComponent">ns=2;s={<xsl:value-of select="$ObjectId"/>}_<xsl:value-of select="@Name"/>
			</Reference>
		</xsl:for-each>
	</xsl:template>

<!-- ************************************************************************
***  
***  Hierarchical elements
***
****************************************************************************** -->
	<!-- .........................................................................
		External Interfaces
	.........................................................................-->
	<xsl:template match="ExternalInterface">
		<!-- Get object variables -->
		<xsl:variable name="ObjectName" select="../@Name"/>
		<xsl:variable name="ObjectId">
			<xsl:choose>
				<xsl:when test="../@ID!=''">{<xsl:value-of select="../@ID"/>}</xsl:when>
				<xsl:otherwise><xsl:value-of select="../@Name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="ObjectNodeId">
			<xsl:choose>
				<xsl:when test="../@ID!=''">g=<xsl:value-of select="$ObjectId"/></xsl:when>
				<xsl:otherwise>s=<xsl:value-of select="$ObjectId"/></xsl:otherwise>
			</xsl:choose>		
		</xsl:variable>
		<xsl:comment>
			<xsl:text>ExternalInterface: </xsl:text>
			<xsl:value-of select="$ObjectName"/>.<xsl:value-of select="@Name"/>
		</xsl:comment>
		<UAObject>
			<xsl:attribute name="NodeId">ns=2;s=<xsl:value-of select="$ObjectId"/>_<xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="ParentNodeId">ns=2;<xsl:value-of select="$ObjectNodeId"/></xsl:attribute>
			<xsl:attribute name="DataType">String</xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:comment>TODO: correct TypeDefinition</xsl:comment>
			<References>
				<!--Reference ReferenceType="HasComponent" IsForward="False"></Reference-->
				<Reference ReferenceType="HasTypeDefinition">i=68</Reference>
			</References>
		</UAObject>
	</xsl:template>
	<!-- .........................................................................
		InternalElements
	.........................................................................-->
	<xsl:template match="InternalElement">
		<!-- Parse SystemUnitClass -->
		<xsl:variable name="UCName" select="substring-before(@RefBaseSystemUnitPath,'/')"/>
		<xsl:variable name="UCContent">
			<xsl:if test="$UCName!= '' and $UCName!= 'AutomationMLBaseRoleClassLib/AutomationMLBaseRole'">
				<xsl:call-template name="GetClass">
					<xsl:with-param name="path" select="@RefBaseSystemUnitPath"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<!-- Create UAObject -->
		<UAObject>
			<xsl:attribute name="NodeId">ns=2;g={<xsl:value-of select="@ID"/>}</xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName><xsl:value-of select="@Name"/></DisplayName>
			<xsl:if test="Description">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<References>
				<!-- Reference to class definition -->
				<xsl:comment>
					<xsl:text>Class definition</xsl:text>
				</xsl:comment>
				<Reference ReferenceType="HasTypeDefinition">ns=<xsl:value-of select="$UCName"/>;s=<xsl:value-of select="exslt:node-set($UCContent)/SystemUnitClass/@Name"/></Reference>
				<xsl:call-template name="References">
					<xsl:with-param name="ObjectName" select="@Name"/>
					<xsl:with-param name="ObjectId" select="@ID"/>
				</xsl:call-template>
			</References>
		</UAObject>
		<!-- Create referred UAVariables and UAObjects -->
		<xsl:apply-templates select="@ID|node()"/>
	</xsl:template>

</xsl:stylesheet>
