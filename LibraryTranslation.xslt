<?xml version="1.0" encoding="UTF-8"?>
<!--TODO: Change xsi:noNamespaceSchemaLocation="CAEX_ClassModel_V2.15.xsd" schema here to CAEX V3-->
<xsl:stylesheet version="2.0" 
	xmlns:fn2="http://whatever"

	xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	exclude-result-prefixes="#default xsi xsl exslt fn" 
	xmlns:caex="http://www.dke.de/CAEX" 
	xmlns:exslt="http://exslt.org/common">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<!--xsl:stylesheet version="2.0" 
		xmlns="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd"
		xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes=" xsl exslt fn" xmlns:exslt="http://exslt.org/common">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/-->
	<!--<xsl:function name="exslt:node-set">
		<xsl:param name="rtf"/>
		<xsl:sequence select="$rtf"/>
	</xsl:function>-->
	
	<xsl:template name="ClassReferences">
		<xsl:variable name="NsId">
			<xsl:call-template name="GetNamespaceId"/>
		</xsl:variable>
		<xsl:variable name="NsName">
			<xsl:call-template name="GetNamespace"/>
		</xsl:variable>
		<xsl:variable name="LibId">
			<xsl:for-each select="ancestor::*[name()='InterfaceClassLib' or name()='RoleClassLib' or name()='SystemUnitClassLib'  or name()='AttributeTypeLib']">
				<xsl:value-of select="fn2:remove-space(name(.))"/>
			</xsl:for-each>
		</xsl:variable>

		<References>
			<xsl:comment>
				<xsl:value-of select="concat('Library: ', $NsName)"/>
			</xsl:comment>
			<!--Reference ReferenceType="HasComponent" IsForward="false">
				<xsl:value-of select="concat('ns=', $NsId,';s=Library')"/>
			</Reference-->
			<Reference ReferenceType="HasComponent" IsForward="false">
				<xsl:value-of select="concat('ns=', $NsId,';s=',$LibId)"/>
			</Reference>
			<!-- Class hierarchy -->
			<xsl:comment>Parent class</xsl:comment>
			<Reference ReferenceType="HasSubtype" IsForward="false">
				<xsl:choose>
					<xsl:when test="ancestor::caex:InterfaceClass[1]">
						<xsl:value-of select="concat('ns=', $NsId, ';s=', ancestor::caex:InterfaceClass[1]/@Name)"/>
					</xsl:when>
					<xsl:when test="ancestor::caex:RoleClass[1]">
						<xsl:value-of select="concat('ns=', $NsId, ';s=', ancestor::caex:RoleClass[1]/@Name)"/>
					</xsl:when>
					<xsl:when test="ancestor::caex:SystemUnitClass[1]">
						<xsl:value-of select="concat('ns=', $NsId, ';s=', ancestor::caex:SystemUnitClass[1]/@Name)"/>
					</xsl:when>
					<xsl:when test="ancestor::caex:AttributeType[1]">
						<xsl:value-of select="concat('ns=', $NsId, ';s=', ancestor::caex:AttributeType[1]/@Name)"/>
					</xsl:when>
					<xsl:when test="@RefBaseClassPath">
						<xsl:variable name="BaseClass">
							<xsl:call-template name="GetClass">
								<xsl:with-param name="path" select="@RefBaseClassPath"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="ParentNS">
							<xsl:call-template name="GetNamespaceIdByName">
								<xsl:with-param name="Namespace">
									<xsl:value-of select="substring-before(@RefBaseClassPath,'/')"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="concat('ns=', $ParentNS, ';s=', fn2:remove-space(exslt:node-set($BaseClass)/*/@Name))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>CAEXObjectType</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</Reference>
			<xsl:call-template name="References">
				<xsl:with-param name="ObjectName" select="@Name"/>
				<xsl:with-param name="ObjectId">
					<xsl:choose>
						<xsl:when test="@ID!=''">
							<xsl:value-of select="@ID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@Name"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="ObjectIdType">
					<xsl:choose>
						<xsl:when test="@ID!=''">
							<xsl:value-of select="'g'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'s'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="Namespace" select="$NsId"/>
			</xsl:call-template>
		</References>
	</xsl:template>
	<xsl:template name="Library">
		<xsl:variable name="NsId">
			<xsl:call-template name="GetNamespaceId"/>
		</xsl:variable>
		<xsl:variable name="LibId">
			<!--xsl:text>Library</xsl:text-->
			<xsl:value-of select="fn2:remove-space(name(.))"/>
		</xsl:variable>
		<xsl:comment>
			Libraries:
			===============================================
			TODOs:
				- is there a maximum length for NodeId?
				- how do we handle very long lib names -> generate short name?
		</xsl:comment>
		<UAObject>
			<xsl:attribute name="NodeId">
				<xsl:value-of select="concat('ns=', $NsId, ';s=', $LibId)"/>
			</xsl:attribute>
			<!--xsl:attribute name="Name">
				<xsl:value-of select="@Name"/>
			</xsl:attribute-->
			<xsl:attribute name="BrowseName">
				<xsl:value-of select="@Name"/>
			</xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="caex:Description!=''">
				<Description>
					<xsl:value-of select="caex:Description"/>
				</Description>
			</xsl:if>
			<References>
				<xsl:if test="caex:Version">
					<Reference ReferenceType="HasProperty">
						<xsl:value-of select="concat('ns=', $NsId, ';s=', $LibId, '_Version')"/>
					</Reference>
				</xsl:if>
				<Reference ReferenceType="HasTypeDefinition">i=61</Reference>
				<xsl:choose>
					<xsl:when test="name(.)='InterfaceClassLib'">
						<xsl:comment>Collection of InterfaceClassLib</xsl:comment>
						<Reference ReferenceType="Organizes" IsForward="false">ns=1;i=5008</Reference>
						<Reference ReferenceType="HasComponent" IsForward="false">ns=2;s=CAEXFile_InterfaceClassLibs</Reference>
					</xsl:when>
					<xsl:when test="name(.)='RoleClassLib'">
						<xsl:comment>Collection of RoleClassLib</xsl:comment>
						<Reference ReferenceType="Organizes" IsForward="false">ns=1;i=5009</Reference>
						<Reference ReferenceType="HasComponent" IsForward="false">ns=2;s=CAEXFile_RoleClassLibs</Reference>
					</xsl:when>
					<xsl:when test="name(.)='SystemUnitClassLib'">
						<xsl:comment>Collection of SystemUnitClassLib</xsl:comment>
						<Reference ReferenceType="Organizes" IsForward="false">ns=1;i=5010</Reference>
						<Reference ReferenceType="HasComponent" IsForward="false">ns=2;s=CAEXFile_SystemUnitClassLibs</Reference>
					</xsl:when>
					<xsl:when test="name(.)='AttributeTypeLib'">
						<xsl:comment>TODO: AttributeTypeLib not supported, yet.</xsl:comment>
						<xsl:comment>Collection of AttributeTypeLib</xsl:comment>
						<Reference ReferenceType="Organizes" IsForward="false">ns=1;i=?</Reference>
						<Reference ReferenceType="HasComponent" IsForward="false">ns=2;s=CAEXFile_AttributeTypeLibs</Reference>
					</xsl:when>
				</xsl:choose>
				<xsl:comment>TODO: what is the correct way to list all elements of the Lib?</xsl:comment>
				<xsl:comment><xsl:value-of select="concat('List of included ', fn:replace(name(), 'Lib', ''))"/></xsl:comment>
				<xsl:for-each select=".//*[name()='RoleClass' or name()='SystemUnitClass' or name()='InterfaceClass' or name()='AttributeType']">
					<Reference ReferenceType="HasComponent"><xsl:value-of select="concat('ns=',$NsId, ';s=',fn2:remove-space(@Name))"/></Reference>
				</xsl:for-each>
			</References>
		</UAObject>
	</xsl:template>
	<!-- .........................................................................
		InterfaceClassLib: Create UAObjectTypes
	.........................................................................-->
	<xsl:template match="caex:InterfaceClassLib">
		<xsl:comment>
			InterfaceClassLib: <xsl:value-of select="@Name"/>
			==================================================
			TODOs:
				- How to handle DefaultValues for attributes?
				- What is the corresponding UAObjectType for AutomationMLBaseInterface?
				- How to handle if the parent interface is not specified in the InterfaceClassLibs of the document?
				- compare to line 79ff. https://github.com/OPCFoundation/UA-Nodeset/blob/latest/AML/Opc.Ua.AMLLibraries.NodeSet2.xml
					- why is there in InternalLink (ns=1;i=4002) to AutomationMLBaseInterface (ns=2;i=22)?
					- why is there an additional ID attribute (ns=2;i=2)?
		</xsl:comment>
		<xsl:call-template name="Library"/>
		<xsl:apply-templates select="*"/>
	</xsl:template>
	<xsl:template match="//caex:InterfaceClass">
		<xsl:variable name="NsId">
			<xsl:call-template name="GetNamespaceId"/>
		</xsl:variable>
		<xsl:comment><xsl:value-of select="concat('InterfaceClass: ', @Name)"/></xsl:comment>
		<UAObjectType>
			<xsl:attribute name="NodeId">
				<xsl:value-of select="concat('ns=', $NsId, ';s=', fn2:remove-space(@Name))"/>
			</xsl:attribute>
			<xsl:attribute name="BrowseName">
				<xsl:value-of select="@Name"/>
			</xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description>
					<xsl:value-of select="Description"/>
				</Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>
	<!-- .........................................................................
		RoleClassLib: Create UAObjectTypes
	.........................................................................-->
	<xsl:template match="caex:RoleClassLib">
		<xsl:comment>
			RoleClassLib: <xsl:value-of select="@Name"/>
			==================================================
			TODOs:
				- What was the correct translation for an RoleClass?
				- Why is the lib modelled as UAObject?
		</xsl:comment>
		<xsl:call-template name="Library"/>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="//caex:RoleClass">
		<xsl:variable name="NsId">
			<xsl:call-template name="GetNamespaceId"/>
		</xsl:variable>
		<xsl:comment><xsl:value-of select="concat('RoleClass: ', @Name)"/></xsl:comment>
		<UAObjectType>
			<xsl:attribute name="NodeId">
				<xsl:value-of select="concat('ns=', $NsId, ';s=', fn2:remove-space(@Name))"/>
			</xsl:attribute>
			<xsl:attribute name="BrowseName">
				<xsl:value-of select="@Name"/>
			</xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description>
					<xsl:value-of select="Description"/>
				</Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>
	<!-- .........................................................................
		SystemUnitClassLib: Create UAObjectTypes
	.........................................................................-->
	<xsl:template match="caex:SystemUnitClassLib">
		<xsl:comment>
			SystemUnitClassLib: <xsl:value-of select="@Name"/>
			==================================================
			TODOs:
				- What was the correct translation for a SystemUnitClass?
				- Why is the lib modelled as UAObject?
		</xsl:comment>
		<xsl:call-template name="Library"/>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="//caex:SystemUnitClass">
		<xsl:variable name="NsId">
			<xsl:call-template name="GetNamespaceId"/>
		</xsl:variable>
		<xsl:comment><xsl:value-of select="concat('SystemUnitClass: ', @Name)"/></xsl:comment>
		<UAObjectType>
			<xsl:attribute name="NodeId">
				<xsl:value-of select="concat('ns=', $NsId, ';s=', fn2:remove-space(@Name))"/>
			</xsl:attribute>
			<xsl:attribute name="BrowseName">
				<xsl:value-of select="@Name"/>
			</xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description>
					<xsl:value-of select="Description"/>
				</Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>
	<!-- .........................................................................
		AttributeTypeLib: Create UAObjectTypes
	.........................................................................-->
	<xsl:template match="caex:AttributeTypeLib">
		<xsl:comment>
			AttributeTypeLib: <xsl:value-of select="@Name"/>
			==================================================
			TODOs:
				- What was the correct translation for a AttributeType?
		</xsl:comment>
		<xsl:call-template name="Library"/>
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	<xsl:template match="//caex:AttributeType">
		<xsl:variable name="NsId">
			<xsl:call-template name="GetNamespaceId"/>
		</xsl:variable>
		<xsl:comment><xsl:value-of select="concat('AttributeType: ', @Name)"/></xsl:comment>
		<UAObjectType>
			<xsl:attribute name="NodeId">
				<xsl:value-of select="concat('ns=', $NsId, ';s=', fn2:remove-space(@Name))"/>
			</xsl:attribute>
			<xsl:attribute name="BrowseName">
				<xsl:value-of select="@Name"/>
			</xsl:attribute>
			<DisplayName>
				<xsl:value-of select="@Name"/>
			</DisplayName>
			<xsl:if test="Description!=''">
				<Description>
					<xsl:value-of select="Description"/>
				</Description>
			</xsl:if>
			<xsl:call-template name="ClassReferences"/>
		</UAObjectType>
		<xsl:apply-templates select="node()|@*"/>
	</xsl:template>
</xsl:stylesheet>