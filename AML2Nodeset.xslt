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

	<!-- Does not work with MSXSL -->
	<!--xsl:function name="exslt:ends-with">
		<xsl:param name="target"/>
		<xsl:param name="suffix"/>
		<xsl:sequence select="$suffix = substring($target, string-length($target) - string-length($suffix) + 1)"/>
	</xsl:function-->
	
	<!-- Parsing of SystemUnitClassLib, InterfaceClassLib, RoleClassLib-->
	<xsl:include href="LibraryParsing.xslt"/>
	<xsl:include href="DatatypeTranslation.xslt"/>
	<!-- Translation of SystemUnitClassLib, InterfaceClassLib, RoleClassLib-->
	<xsl:include href="LibraryTranslation.xslt"/>
	
	<!-- Collect all namespaces -->
	<xsl:variable name="NamespaceUris">
		<NamespaceUris>
			<Uri>http://opcfoundation.org/UA/AML/</Uri>
			<Uri>http://opcfoundation.org/UA/AML/MyInstances</Uri>
			<xsl:for-each select="//InterfaceClassLib">
				<Uri>
					<xsl:value-of select="concat('http://opcfoundation.org/UA/AML/', @Name)"/>
				</Uri>
			</xsl:for-each>
			<xsl:for-each select="//RoleClassLib">
				<Uri>
					<xsl:value-of select="concat('http://opcfoundation.org/UA/AML/', @Name)"/>
				</Uri>
			</xsl:for-each>
			<xsl:for-each select="//SystemUnitClassLib">
				<Uri>
					<xsl:value-of select="concat('http://opcfoundation.org/UA/AML/', @Name)"/>
				</Uri>
			</xsl:for-each>
		</NamespaceUris>
	</xsl:variable>
	
	<!-- Create Collection as parent for InstanceHierarchies and the differnt types of libraries -->
	<xsl:template name="HierarchicalElement">
		<xsl:param name="Name"/>
		<xsl:param name="ChildName"/>

		<xsl:comment><xsl:value-of select="concat('Collection: CAEXFile.', $Name)"/></xsl:comment>
		<xsl:if test="*[local-name()=$ChildName]">
			<UAObject>
				<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=2;s=CAEXFile_', $Name)"/></xsl:attribute>
				<xsl:attribute name="BrowseName"><xsl:value-of select="$Name"/></xsl:attribute>
				<xsl:attribute name="ParentNodeId"><xsl:value-of select="'ns=2;s=CAEXFile'"/></xsl:attribute>
				<DisplayName><xsl:value-of select="$Name"/></DisplayName>
				<References>
					<Reference ReferenceType="HasComponent" IsForward="false">ns=2;s=CAEXFile</Reference>
					<Reference ReferenceType="HasTypeDefinition">i=61</Reference>
					<xsl:for-each select="*[local-name()=$ChildName]">
						<xsl:comment><xsl:value-of select="concat($ChildName, ': ', @Name)"/></xsl:comment>
						<Reference ReferenceType="HasComponent">
						<xsl:choose>
							<xsl:when test="$Name='InstanceHierarchies'">
								<xsl:value-of select="concat('ns=2;InstanceHierarchy_', @Name)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="Namespace">
									<xsl:call-template name="GetNamespace"/>
								</xsl:variable>
								<xsl:value-of select="concat('ns=', $Namespace, ';s=Library')"/>
							</xsl:otherwise>
						</xsl:choose>
						</Reference>
					</xsl:for-each>
				</References>
			</UAObject>
		</xsl:if>
		<xsl:apply-templates select="node()[local-name()=$ChildName]"/>		
	</xsl:template>

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
				- avoid duplicate AdditionalInformation
				- Do we need aliases?? 
					- to be clarified with UA -> Miriam
				    - only used ones or standard template set of aliases
					- purpose? drawback				
				- InternalLinks are not translated, yet.
				- Missing translation for UtcTime/DateTime
				- How to use Table 14 in DataTypeMapping v5.0? -> Add mapping to translation table
				- no HasTypeDefinition available if there was no SystemUnitClass (see "BPR_005E_ExternalDataReference_Examples_Jul2016.aml")
				- use correct HasTypeDefinition
				- are spaces allowed in NodeId string as part if the ID? 
				    - to be clarified with AML if spaces are allowed (Part 1) -> Miriam
					- Example in AR APC all Classes AutomationProjectConfigurationRoleClassLib/DeviceItem Attributes
					- necessary for nodeID (BrowseName keeps space), thus deleted
				- are '{GUID}' and 'GUID' equal? -> will be handled as equivalent
				- InterfaceClasses have no specific UA "base structure", but are also of type ObjectType -> how to distinguish between SUC and IC
				- AdditionalInformation is handled as blackbox (no ID)
				- AdditionalInformation AutomationMLVersion
				- from UA to AML: what if we have no "file name" in UA XML (Nodeset has no name) (which element to use as filename)
				- XSL + script for generation of MD5 hash				
				- How to understand the hierarchical elements (incl. HasTypeDefinition)?
			</xsl:comment>
			<xsl:copy-of select="$NamespaceUris"/>
			<Models>
				<Model ModelUri="http://opcfoundation.org/UA/AMLLibs/">
					<RequiredModel ModelUri="http://opcfoundation.org/UA/AML/"/>
						<RequiredModel ModelUri="http://opcfoundation.org/UA/" Version="1.04" PublicationDate="2019-05-01T00:00:00Z"/>
				</Model>
			</Models>
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
			
			<xsl:comment>
			CAEXFile
			===============
			TODOs:
				- is this the correct translation (AMLFile = Object)? -> currently yes
				- do we really need InstanceHierarchies, InterfaceClassLibs and other organizing elements?
				- How to model ExternalReferences?
			</xsl:comment>

			<UAObject>
				<xsl:attribute name="NodeId"><xsl:value-of select="'ns=2;s=CAEXFile'"/></xsl:attribute>
				<xsl:attribute name="BrowseName"><xsl:value-of select="@FileName"/></xsl:attribute>
				<DisplayName><xsl:value-of select="@FileName"/></DisplayName>
				<xsl:copy-of select="Description"/>
				<References>
					<Reference ReferenceType="HasTypeDefinition">ns=1;i=1005</Reference>
					<xsl:if test="@FileName">
						<xsl:comment>FileName</xsl:comment>
						<Reference ReferenceType="HasProperty">ns=2;s=CAEXFile_FileName</Reference>					
					</xsl:if>
					<xsl:if test="@SchemaVersion">
						<xsl:comment>SchemaVersion</xsl:comment>
						<Reference ReferenceType="HasProperty">ns=2;s=CAEXFile_SchemaVersion</Reference>
					</xsl:if>
					<xsl:comment>InstanceHierarchy</xsl:comment>
					<xsl:if test="//InstanceHierarchy">
						<Reference ReferenceType="HasComponent">ns=2;s=CAEXFile_InstanceHierarchies</Reference>					
					</xsl:if>
					<xsl:comment>Libraries</xsl:comment>
					<xsl:if test="//InterfaceClassLib">
						<Reference ReferenceType="HasComponent">ns=2;s=CAEXFile_InterfaceClassLibs</Reference>					
					</xsl:if>
					<xsl:if test="//RoleClassLib">
						<Reference ReferenceType="HasComponent">ns=2;s=CAEXFile_RoleClassLibs</Reference>					
					</xsl:if>
					<xsl:if test="//SystemUnitClassLib">
						<Reference ReferenceType="HasComponent">ns=2;s=CAEXFile_SystemUnitClassLibs</Reference>					
					</xsl:if>
					<xsl:for-each select="AdditionalInformation">
						<xsl:variable name="AttributeName">
							<!--xsl:choose>
								<xsl:when test="name(*[1])!=''"><xsl:value-of select="name(*[1])"/></xsl:when>
								<xsl:when test="name(@*[1])!=''"><xsl:value-of select="name(@*[1])"/></xsl:when>
								<xsl:otherwise>AdditionalInformation</xsl:otherwise>
							</xsl:choose-->
							<xsl:value-of select="concat('AdditionalInformation_', position())"/>
						</xsl:variable>	
						<xsl:comment><xsl:value-of select="concat('AdditionalInformation: ', $AttributeName)"/></xsl:comment>
						<Reference ReferenceType="HasProperty"><xsl:value-of select="concat('ns=2;s=CAEXFile_', $AttributeName)"/></Reference>
					</xsl:for-each>
					<xsl:comment>TODO: is this correct? (AutomationMLFiles)</xsl:comment>
					<Reference ReferenceType="Organizes" IsForward="false">ns=1;i=5006</Reference>
				</References>
				</UAObject>
							
			<xsl:apply-templates select="@FileName"/>
			<xsl:apply-templates select="@SchemaVersion"/>
			
			<xsl:comment>
			AdditionalInformation
			===============
			TODOs:
 				- How to handle multiple AdditionalInformation
					    use first ElementName (or AttributeName) as BrowseName/ID/DisplayName
						define specific SystemUnitClass or RoleClass						
				- do we need an extra UAObjectType for additional information? -> no use content of value as marker
			    - which versione (1. or 2.) is the correct translation of an AdditionalInformation?
			</xsl:comment>
			<xsl:apply-templates select="node()[local-name()='AdditionalInformation']"/>
			
			<xsl:comment>
			InstanceHierarchies
			===============
			TODOs:
				- do we need a InstanceHierarchies node? What was the result of the discussion?
			    - Complete References
				- Do we need BackwardReferences here?
				- Test child of AutomationMLBaseRole/UABaseObjectType
				- currently only type definition from Libraries are supported -> support HasTypeDefinition from current namespace
			</xsl:comment>
			<xsl:call-template name="HierarchicalElement">
				<xsl:with-param name="Name" select="'InstanceHierarchies'"/>
				<xsl:with-param name="ChildName" select="'InstanceHierarchy'"/>
			</xsl:call-template>

			<xsl:comment>
			InterfaceClassLibs
			===============
			TODOs:
				- do we need a InterfaceClassLibs node? What was the result of the discussion?
			</xsl:comment>

			<xsl:call-template name="HierarchicalElement">
				<xsl:with-param name="Name" select="'InterfaceClassLibs'"/>
				<xsl:with-param name="ChildName" select="'InterfaceClassLib'"/>
			</xsl:call-template>

			<xsl:comment>
			RoleClassLibs
			===============
			TODOs:
				- ...
			</xsl:comment>

			<xsl:call-template name="HierarchicalElement">
				<xsl:with-param name="Name" select="'RoleClassLibs'"/>
				<xsl:with-param name="ChildName" select="'RoleClassLib'"/>
			</xsl:call-template>

			<xsl:comment>
			SystemUnitClassLibs
			===============
			TODOs:
				- ...
			</xsl:comment>

			<xsl:call-template name="HierarchicalElement">
				<xsl:with-param name="Name" select="'SystemUnitClassLibs'"/>
				<xsl:with-param name="ChildName" select="'SystemUnitClassLib'"/>
			</xsl:call-template>			
		</UANodeSet>
	</xsl:template>
	<!-- .........................................................................
		InstanceHierarchy: Create UAObjecs
	.........................................................................-->
	<xsl:template match="InstanceHierarchy">	
		<xsl:comment><xsl:value-of select="concat('InstanceHierarchy: ', @Name)"/></xsl:comment> 
		<UAObject>
			<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=2;s=InstanceHierarchy_', @Name)"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName><xsl:value-of select="@Name"/></DisplayName>
			<xsl:copy-of select="Description"/>
			<References>
				<Reference ReferenceType="HasTypeDefinition">i=61</Reference>
				<xsl:comment>TODO: is this correct? (AutomationMLInstanceHierarchies)</xsl:comment>
				<Reference ReferenceType="Organizes" IsForward="false">ns=1;i=5005</Reference>
				<xsl:comment>Backward reference to CAEX InstanceHierarchies</xsl:comment>
				<Reference ReferenceType="HasComponent" IsForward="false">ns=2;s=CAEXFile_InstanceHierarchies</Reference>
				<xsl:for-each select="InternalElement">
					<xsl:comment><xsl:value-of select="concat('InternalElement: ', @Name)"/></xsl:comment>
					<Reference ReferenceType="HasComponent"><xsl:value-of select="concat('ns=2;g={', @ID, '}')"/></Reference>				
				</xsl:for-each>
			</References>
		</UAObject>
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
		<xsl:param name="ParentIdType"/>
		<xsl:param name="Namespace"/>
		<xsl:param name="AttributeName"/>
		<xsl:param name="AttributeValue"/>
		<!-- Create property -->
		<xsl:comment><xsl:text>Attribute: </xsl:text><xsl:value-of select="$ObjectName"/>.<xsl:value-of select="$AttributeName"/></xsl:comment>
		<UAVariable>
			<xsl:attribute name="NodeId">
				<!--xsl:value-of select="concat($Namespace, ';s=', $ParentId, '_', $AttributeName)"/-->
				<xsl:choose>
					<xsl:when test="$ParentIdType='g' and starts-with($ParentId, '{')">
						<xsl:value-of select="concat($Namespace, ';s=', $ParentId, '_',$AttributeName)"/>
					</xsl:when>
					<xsl:when test="$ParentIdType='g'">
						<xsl:value-of select="concat($Namespace, ';s={', $ParentId, '}_',$AttributeName)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($Namespace, ';s=', $ParentId, '_', $AttributeName)"/>					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="$AttributeName"/></xsl:attribute>
			<xsl:attribute name="ParentNodeId">
				<xsl:choose>
					<xsl:when test="$ParentIdType='g' and starts-with($ParentId, '{')">
						<xsl:value-of select="concat($Namespace, ';g=', $ParentId)"/>
					</xsl:when>
					<xsl:when test="$ParentIdType='g'">
						<xsl:value-of select="concat($Namespace, ';g={', $ParentId, '}')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($Namespace, ';s=', $ParentId)"/>					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
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

	<xsl:template match="@FileName">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>		
	
		<!-- Create FileName property -->
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName" select="'CAEXFile'"/>
			<xsl:with-param name="ParentId" select="'CAEXFile'"/>
			<xsl:with-param name="ParentIdType" select="'s'"/>
			<xsl:with-param name="Namespace" select="concat('ns=', $Namespace)"/>
			<xsl:with-param name="AttributeName" select="'FileName'"/>
			<xsl:with-param name="AttributeValue"><xsl:value-of select="."/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="@SchemaVersion">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>		
	
		<!-- Create SchemaVersion property -->
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName" select="'CAEXFile'"/>
			<xsl:with-param name="ParentId" select="'CAEXFile'"/>
			<xsl:with-param name="ParentIdType" select="'s'"/>
			<xsl:with-param name="Namespace" select="concat('ns=', $Namespace)"/>
			<xsl:with-param name="AttributeName" select="'SchemaVersion'"/>
			<xsl:with-param name="AttributeValue"><xsl:value-of select="."/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="@ID">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>
		
		<!-- Create AML-ID property -->
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName" select="../@Name"/>
			<xsl:with-param name="ParentId" select="../@ID"/>
			<xsl:with-param name="ParentIdType" select="'g'"/>
			<xsl:with-param name="Namespace" select="concat('ns=', $Namespace)"/>
			<xsl:with-param name="AttributeName" select="'ID'"/>
			<xsl:with-param name="AttributeValue">
				<xsl:choose>
					<xsl:when test="starts-with(../@ID, '{')">
						<xsl:value-of select="../@ID"/>					
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('{', ../@ID, '}')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param> 
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Version">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="local-name(..)='InterfaceClassLib' or local-name(..)='RoleClassLib' or local-name(..)='SystemUnitClassLib'">
				<xsl:call-template name="StringAttributeVariable">
					<xsl:with-param name="ObjectName" select="../@Name"/>
					<xsl:with-param name="ParentId" select="'Library'"/>
					<xsl:with-param name="ParentIdType" select="'s'"/>
					<xsl:with-param name="Namespace" select="concat('ns=', $Namespace)"/>
					<xsl:with-param name="AttributeName" select="'Version'"/>
					<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="local-name(..)='InstanceHierarchy'">
				<xsl:call-template name="StringAttributeVariable">
					<xsl:with-param name="ObjectName" select="../@Name"/>
					<xsl:with-param name="ParentId" select="'InstanceHierarchy'"/>
					<xsl:with-param name="ParentIdType" select="'s'"/>
					<xsl:with-param name="Namespace" select="'ns=2'"/>
					<xsl:with-param name="AttributeName" select="'Version'"/>
					<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="StringAttributeVariable">
					<xsl:with-param name="ObjectName" select="../@Name"/>
					<xsl:with-param name="ParentId" select="../@ID"/>
					<xsl:with-param name="ParentIdType" select="'g'"/>
					<xsl:with-param name="Namespace" select="'ns=2'"/>
					<xsl:with-param name="AttributeName" select="'Version'"/>
					<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--xsl:template match="Revision"></xsl:template-->

	<xsl:template match="Copyright">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName" select="../@Name"/>
			<xsl:with-param name="ParentId" select="../@ID"/>
			<xsl:with-param name="ParentIdType" select="'g'"/>
			<xsl:with-param name="Namespace" select="concat('ns=', $Namespace)"/>
			<xsl:with-param name="AttributeName" select="'Copyright'"/>
			<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*[name()!='CAEXFile']/AdditionalInformation">
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName" select="../@Name"/>
			<xsl:with-param name="ParentId" select="../@ID"/>
			<xsl:with-param name="ParentIdType" select="'g'"/>
			<xsl:with-param name="Namespace" select="'ns=2'"/>
			<xsl:with-param name="AttributeName" select="concat('AdditionalInformation_', position())"/>
			<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
		</xsl:call-template>	
	</xsl:template>

	<xsl:template match="CAEXFile/AdditionalInformation">
		<!--xsl:comment>Version 1:</xsl:comment-->
		<xsl:variable name="AttributeName">
			<xsl:choose>
				<xsl:when test="name(*[1])!=''"><xsl:value-of select="name(*[1])"/></xsl:when>
				<xsl:when test="name(@*[1])!=''"><xsl:value-of select="name(@*[1])"/></xsl:when>
				<xsl:otherwise>AdditionalInformation</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	


		<!-- Create property -->
		<xsl:comment><xsl:text>Attribute: </xsl:text>CAEXFile.<xsl:value-of select="$AttributeName"/></xsl:comment>
		<UAVariable>
			<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=2;s=CAEXFile_AdditionalInformation_', position())"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="$AttributeName"/></xsl:attribute>
			<xsl:attribute name="ParentNodeId">ns=2;s=CAEXFile</xsl:attribute>
			<xsl:attribute name="DataType">String</xsl:attribute>
			<DisplayName><xsl:value-of select="$AttributeName"/></DisplayName>
			<References>
				<Reference ReferenceType="HasTypeDefinition">i=68</Reference>
			</References>
			<Value>
				<String xmlns="http://opcfoundation.org/UA/2008/02/Types.xsd">
					<xsl:copy-of select="."/>
				</String>
			</Value>
		</UAVariable>

		<!--xsl:comment>Version 2:</xsl:comment>
		<xsl:call-template name="StringAttributeVariable">
			<xsl:with-param name="ObjectName">CAEXFile</xsl:with-param>
			<xsl:with-param name="ParentId">CAEXFile</xsl:with-param>
			<xsl:with-param name="ParentIdType" select="'s'"/>
			<xsl:with-param name="Namespace">ns=2</xsl:with-param>
			<xsl:with-param name="AttributeName">AdditionalInformation</xsl:with-param>
			<xsl:with-param name="AttributeValue"><xsl:copy-of select="."/></xsl:with-param>
		</xsl:call-template-->	
	</xsl:template>

	<!-- .........................................................................
		Attribute tags of InternalElements and Class definitions
	.........................................................................-->
	<xsl:template match="Attribute">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>
	
		<!-- Get object variables -->
		<xsl:variable name="ObjectId">
			<xsl:choose>
				<xsl:when test="../@ID!='' and starts-with(../@ID, '{')"><xsl:value-of select="../@ID"/></xsl:when>
				<xsl:when test="../@ID!=''"><xsl:value-of select="concat('{', ../@ID, '}')"/></xsl:when>
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
			<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=', $Namespace, ';s=',  $ObjectId, '_', @Name)"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="ParentNodeId"><xsl:value-of select="concat('ns=', $Namespace, ';', $ObjectNodeId)"/></xsl:attribute>
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
		<xsl:param name="ObjectIdType"/>
		<xsl:param name="Namespace"/>

		<xsl:variable name="CompleteNamespace">
			<xsl:choose>
				<xsl:when test="$Namespace">
					<xsl:value-of select="$Namespace"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'2'"/>					
				</xsl:otherwise>
			</xsl:choose>					
		</xsl:variable>

		<xsl:variable name="CompleteObjectId">
			<xsl:choose>
				<xsl:when test="$ObjectIdType='g' and starts-with($ObjectId, '{')">
					<xsl:value-of select="concat('ns=' , $CompleteNamespace, ';s=', $ObjectId, '_')"/>
				</xsl:when>
				<xsl:when test="$ObjectIdType='g'">
					<xsl:value-of select="concat('ns=' , $CompleteNamespace, ';s={', $ObjectId, '}_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('ns=' , $CompleteNamespace, ';s=', $ObjectId, '_')"/>					
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:variable>
		
		<xsl:if test="@ID">
			<!-- Reference to AML-ID property -->
			<xsl:comment>AML-ID</xsl:comment>
			<Reference ReferenceType="HasProperty"><xsl:value-of select="concat($CompleteObjectId, 'ID')"/></Reference>
		</xsl:if>
		<!-- Reference to Version property -->
		<xsl:if test="Version">
			<xsl:comment>Version</xsl:comment>
			<Reference ReferenceType="HasProperty"><xsl:value-of select="concat($CompleteObjectId, 'Version')"/></Reference>
		</xsl:if>
		<!-- References for all Attribute properties -->
		<xsl:for-each select="Attribute">
			<xsl:comment>
				<xsl:text>Attribute: </xsl:text>
				<xsl:value-of select="@Name"/>
			</xsl:comment>
			<Reference ReferenceType="HasProperty"><xsl:value-of select="concat($CompleteObjectId, @Name)"/>
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
			<xsl:variable name="LibNsId">
				<xsl:call-template name="GetNamespaceIdByName">
					<xsl:with-param name="Namespace" select="$RCName"/>
				</xsl:call-template>
			</xsl:variable>
			
			<Reference ReferenceType="HasAMLRoleReference">
				<xsl:value-of select="concat('ns=', $LibNsId, ';s=', exslt:node-set($RCContent)/RoleClass/@Name)"/>				
			</Reference>
		</xsl:for-each>
		<!-- Reference to ExternalInterface objects -->
		<xsl:for-each select="ExternalInterface">
			<xsl:comment>
				<xsl:text>ExternalInterface: </xsl:text>
				<xsl:value-of select="@Name"/>
			</xsl:comment>
			<Reference ReferenceType="HasComponent">
				<xsl:value-of select="concat($CompleteObjectId, @Name)"/>
			</Reference>
		</xsl:for-each>
		<!-- Reference to InternalElement objects -->
		<xsl:for-each select="InternalElement">
			<xsl:comment>
				<xsl:text>InternalElement: </xsl:text>
				<xsl:value-of select="@Name"/>
			</xsl:comment>
			<Reference ReferenceType="HasComponent">
				<xsl:value-of select="concat($CompleteObjectId, @Name)"/>
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
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>	
	
		<!-- Get object variables -->
		<xsl:variable name="ObjectName" select="../@Name"/>
		<xsl:variable name="ObjectId">
			<xsl:choose>			
				<xsl:when test="../@ID!='' and starts-with(../@ID, '{')"><xsl:value-of select="../@ID"/></xsl:when>
				<xsl:when test="../@ID!=''"><xsl:value-of select="concat('{', ../@ID, '}')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="../@Name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="ObjectNodeId">
			<xsl:choose>
				<xsl:when test="../@ID!=''"><xsl:value-of select="concat('g=', $ObjectId)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="concat('s=', $ObjectId)"/></xsl:otherwise>
			</xsl:choose>		
		</xsl:variable>
		<xsl:comment>
			<xsl:text>ExternalInterface: </xsl:text>
			<xsl:value-of select="$ObjectName"/>.<xsl:value-of select="@Name"/>
		</xsl:comment>
		<UAObject>
			<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=', $Namespace, ';s=' , $ObjectId, '_', @Name)"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<xsl:attribute name="ParentNodeId"><xsl:value-of select="concat('ns=', $Namespace, ';', $ObjectNodeId)"/></xsl:attribute>
			<xsl:attribute name="DataType">String</xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<References>
				<!--Reference ReferenceType="HasComponent" IsForward="False"></Reference-->
				<xsl:comment>TODO: correct TypeDefinition</xsl:comment>
				<Reference ReferenceType="HasTypeDefinition">i=68</Reference>
				<xsl:call-template name="References">
					<xsl:with-param name="ObjectName" select="@Name"/>
					<xsl:with-param name="ObjectId" select="@ID"/>						
					<xsl:with-param name="ObjectIdType" select="'g'"/>
					<xsl:with-param name="Namespace" select="$Namespace"/>
				</xsl:call-template>

			</References>
		</UAObject>
		<!-- Create referred UAVariables and UAObjects -->
		<xsl:apply-templates select="@ID|node()"/>
	</xsl:template>
	<!-- .........................................................................
		InternalElements
	.........................................................................-->
	<xsl:template match="InternalElement">
		<xsl:variable name="Namespace">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>	

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
			<xsl:attribute name="NodeId"><xsl:value-of select="concat('ns=', $Namespace, ';g={', @ID, '}')"/></xsl:attribute>
			<xsl:attribute name="BrowseName"><xsl:value-of select="@Name"/></xsl:attribute>
			<DisplayName><xsl:value-of select="@Name"/></DisplayName>
			<xsl:if test="Description">
				<Description><xsl:value-of select="Description"/></Description>
			</xsl:if>
			<References>
				<xsl:if test="exslt:node-set($UCContent)/*!=''">
					<!-- Reference to class definition -->
					<xsl:comment>
						<xsl:text>Class definition</xsl:text>
					</xsl:comment>
					<Reference ReferenceType="HasTypeDefinition">
						<xsl:value-of select="concat('ns=', $UCName, ';s=', exslt:node-set($UCContent)/SystemUnitClass/@Name)"/>
					</Reference>
				</xsl:if>
				<xsl:call-template name="References">
					<xsl:with-param name="ObjectName" select="@Name"/>
					<xsl:with-param name="ObjectId" select="@ID"/>
					<xsl:with-param name="ObjectIdType" select="'g'"/>
					<xsl:with-param name="Namespace" select="$Namespace"/>
				</xsl:call-template>
			</References>
		</UAObject>
		<!-- Create referred UAVariables and UAObjects -->
		<xsl:apply-templates select="@ID|node()"/>
	</xsl:template>

</xsl:stylesheet>
