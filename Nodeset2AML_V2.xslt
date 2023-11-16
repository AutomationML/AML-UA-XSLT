<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:ua="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd" 
	xmlns:uaTypes="http://opcfoundation.org/UA/2008/02/Types.xsd" 
	xmlns:exslt="http://exslt.org/common" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns="http://www.dke.de/CAEX"
	xmlns:caex="http://www.dke.de/CAEX"

	exclude-result-prefixes="xsl ua uaTypes exslt">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="text()"/>
	<!-- Laut Microsoft muss man die Funktionalität mit „XsltSettings.EnableScript“ aktivieren, 
     bevor man XslTransform startet: 
	 https://docs.microsoft.com/de-de/dotnet/api/system.xml.xsl.xsltsettings.enablescript?view=net-5.0
	-->
	<xsl:function name="exslt:node-set">
		<xsl:param name="rtf"/>
		<xsl:sequence select="$rtf"/>
	</xsl:function>
	
	<xsl:include href="DatatypeTranslation.xslt"/>


<!-- *************************************************************
***
*** Global variables
***
************************************************************* -->
	
	<xsl:variable name="UANodeSet">
		<xsl:copy-of select="."/>
	</xsl:variable>

	<!-- list of all references -->
	<xsl:variable name="References">
		<xsl:variable name="AllRefs">
			<xsl:for-each select="ua:UANodeSet//ua:Reference">
				<Reference>
					<xsl:copy-of select="@ReferenceType"/>
					<xsl:choose>
						<xsl:when test="@IsForward=false()">
							<xsl:attribute name="Source" select="."/>
							<xsl:attribute name="Target" select="../../@NodeId"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="Source" select="../../@NodeId"/>
							<xsl:attribute name="Target" select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</Reference>
			</xsl:for-each>
		</xsl:variable>

		<!-- remove duplicated -->
		<References>
			<xsl:for-each select="$AllRefs/caex:Reference">
				<xsl:variable name="Source" select="@Source"/>
				<xsl:variable name="Target" select="@Target"/>
				<xsl:if test="not(preceding-sibling::caex:Reference[@Target=$Target and @Source=$Source])">
					<xsl:copy-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</References>
	</xsl:variable>

	<!-- Top-Down-Approach: 
			- find all ObjectTypes that match to AML2UA library mapping 	
	-->
	<xsl:variable name="RoleClassLibs">
		<xsl:call-template name="GetAllObjectsByRefType">
			<xsl:with-param name="RefType" select="'Organizes'"/>
			<xsl:with-param name="RefId" select="'ns=1;i=5009'"/>
			<xsl:with-param name="IsForward" select="false()"/>
		</xsl:call-template>	
	</xsl:variable>
	<xsl:variable name="SystemUnitClassLibs">
		<xsl:call-template name="GetAllObjectsByRefType">
			<xsl:with-param name="RefType" select="'Organizes'"/>
			<xsl:with-param name="RefId" select="'ns=1;i=5010'"/>
			<xsl:with-param name="IsForward" select="false()"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="InterfaceClassLibs">
		<xsl:call-template name="GetAllObjectsByRefType">
			<xsl:with-param name="RefType" select="'Organizes'"/>
			<xsl:with-param name="RefId" select="'ns=1;i=5008'"/>
			<xsl:with-param name="IsForward" select="false()"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="InstanceHierarchies">
		<xsl:call-template name="GetAllObjectsByRefType">
			<xsl:with-param name="RefType" select="'Organizes'"/>
			<xsl:with-param name="RefId" select="'ns=1;i=5005'"/>
			<xsl:with-param name="IsForward" select="false()"/>
		</xsl:call-template>
	</xsl:variable>
	
	<!-- collect all libraries -->
	<xsl:variable name="Libraries">
		<xsl:for-each select="exslt:node-set(ua:UANodeSet)//ua:NamespaceUris/ua:Uri">
			<xsl:variable name="Uri">
				<xsl:choose>
					<xsl:when test="fn:ends-with(., '/')">
						<xsl:value-of select="substring(., 1, string-length(.) - 1)"/>
					</xsl:when>				
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<Library>				
				<xsl:attribute name="Name">
					<xsl:call-template name="GetSubstringAfterLast">
						<xsl:with-param name="input" select="$Uri"/>
						<xsl:with-param name="pattern" select="'/'"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="Id">
					<xsl:value-of select="position()"/>
				</xsl:attribute>
				<Uri><xsl:value-of select="."/></Uri>

			</Library>
		</xsl:for-each>
	</xsl:variable>

	<!-- 
		Bottom-up-Approach: 
			- get all type definitions
			- find out those type definitions that are derived from types of other NSs
			- if available: locate library element for those top-level types
			- otherwise define library elements

		Generate the tree of libraries, identify the library type and add first level classes for the libraries 
	-->
	<xsl:variable name="LibraryTree">
		<Libraries>
			<xsl:for-each select="$Libraries/*">
				<xsl:variable name="LibId" select="concat('ns=', @Id, ';')"/>
				<xsl:variable name="LibName" select="@Name"/>
				<xsl:copy-of select="$RoleClassLibs"/>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<!-- check the library type if available -->
					<xsl:choose>
						<xsl:when test="$SystemUnitClassLibs//ua:UAObject[ua:DisplayName=$LibName]">
							<xsl:attribute name="ClassType" select="'SystemUnitClass'"/>
							<xsl:copy-of select="$SystemUnitClassLibs//ua:UAObject[ua:DisplayName=$LibName]"/>
						</xsl:when>
						<xsl:when test="$InterfaceClassLibs//ua:UAObject[ua:DisplayName=$LibName]">
							<xsl:attribute name="ClassType" select="'InterfaceClass'"/>
							<xsl:copy-of select="$InterfaceClassLibs//ua:UAObject[ua:DisplayName=$LibName]"/>
						</xsl:when>
						<xsl:when test="$RoleClassLibs//ua:UAObject[ua:DisplayName=$LibName]">
							<xsl:attribute name="ClassType" select="'RoleClass'"/>
							<xsl:copy-of select="$RoleClassLibs//ua:UAObject[ua:DisplayName=$LibName]"/>
						</xsl:when>
					</xsl:choose>
					
					<!-- copy all References that have their target in this Lib but the source outside of the Lib -->
					<xsl:for-each select="
						$References//caex:Reference[@ReferenceType='HasSubtype' and 
												not(fn:starts-with(@Source, $LibId)) and 
												fn:starts-with(@Target, $LibId)]">
						<xsl:copy>
							<xsl:copy-of select="@*"/>								
						</xsl:copy>
					</xsl:for-each>
				</xsl:copy>
			</xsl:for-each>
			
		</Libraries>
	</xsl:variable>

<!-- *************************************************************
***
*** Helper
***
************************************************************* -->
	<xsl:template name="GetAttributeValue">
		<xsl:param name="NodeId"/>
		<xsl:value-of select="//ua:UAVariable[@NodeId=$NodeId]/ua:Value/uaTypes:String"/>
	</xsl:template>
	<xsl:template name="GetAttributeByDisplayName">
		<xsl:param name="Parent"/>
		<xsl:param name="DisplayName"/>
		<xsl:param name="ReferenceType"/>
		<xsl:for-each select="$References/*/caex:Reference[@ReferenceType=$ReferenceType and @Source=$Parent]">
			<xsl:variable name="Target" select="@Target"/>
			<xsl:copy-of select="$UANodeSet//*[@NodeId=$Target and ua:DisplayName=$DisplayName]"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="GetAttributeValueByDisplayName">
		<xsl:param name="Parent"/>
		<xsl:param name="DisplayName"/>
		<xsl:param name="ReferenceType"/>
		<xsl:variable name="Attribute">
			<xsl:call-template name="GetAttributeByDisplayName">
				<xsl:with-param name="Parent" select="$Parent"/>
				<xsl:with-param name="DisplayName" select="$DisplayName"/>
				<xsl:with-param name="ReferenceType" select="$ReferenceType"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="exslt:node-set($Attribute)//ua:Value/uaTypes:String"/>
	</xsl:template>
	<xsl:template name="GetAttributeByReferenceType">
		<xsl:param name="Parent"/>
		<xsl:param name="ReferenceType"/>
		<xsl:for-each select="$References/*/caex:Reference[@ReferenceType=$ReferenceType and @Source=$Parent]">
			<xsl:variable name="Target" select="@Target"/>
			<xsl:copy-of select="$UANodeSet//*[@NodeId=$Target]"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="GetAllObjectsByRefType">
		<xsl:param name="RefType"/>
		<xsl:param name="RefId"/>
		<xsl:param name="IsForward" select="true()"/>
		<xsl:choose>
			<xsl:when test="$IsForward">
				<xsl:for-each select="$References//*[@ReferenceType=$RefType and @Target=$RefId]">
					<xsl:variable name="Source" select="@Source"/>
					<xsl:copy-of select="$UANodeSet//*[@NodeId=$Source]"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$References//*[@ReferenceType=$RefType and @Source=$RefId]">
					<xsl:variable name="Target" select="@Target"/>
					<xsl:copy-of select="$UANodeSet//*[@NodeId=$Target]"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="GetAttributeValueByTypeDefinition">
		<xsl:param name="Parent"/>
		<xsl:param name="TypeDefinition"/>
		<xsl:param name="ReferenceType"/>
	</xsl:template>
	<xsl:template name="GetElementById">
		<xsl:param name="ID"/>
		<xsl:copy-of select="$UANodeSet//*[@NodeId=$ID]"/>
	</xsl:template>
	<xsl:template name="GetSourceElement">
		<xsl:param name="Reference"/>
		<xsl:variable name="Property">
			<xsl:call-template name="GetElementById">
				<xsl:with-param name="ID" select="$Reference/@Target"/>
			</xsl:call-template>
		</xsl:variable>
	</xsl:template>
	<xsl:template name="GetTargetElement">
		<xsl:param name="Reference"/>
		<xsl:variable name="Property">
			<xsl:call-template name="GetElementById">
				<xsl:with-param name="ID" select="$Reference/@Source"/>
			</xsl:call-template>
		</xsl:variable>
	</xsl:template>
	<xsl:template name="GetSubstringAfterLast">
		<xsl:param name="input"/>
		<xsl:param name="pattern"/>
		<xsl:choose>
			<xsl:when test="contains($input, $pattern)">
				<xsl:call-template name="GetSubstringAfterLast">
					<xsl:with-param name="input" select="substring-after($input, $pattern)"/>
					<xsl:with-param name="pattern" select="$pattern"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="CreateAmlId">
		<xsl:variable name="Id">
			<xsl:call-template name="GetAttributeByDisplayName">
				<xsl:with-param name="Parent" select="."/>
				<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
				<xsl:with-param name="DisplayName" select="'ID'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:attribute name="ID">
			<xsl:choose>
				<xsl:when test="exslt:node-set($Id)/*/ua:Value/uaTypes:String!=''">
					<xsl:value-of select="exslt:node-set($Id)/*/ua:Value/uaTypes:String"/>
				</xsl:when>
				<!--TODO GenerateGUID Java-->
				<xsl:otherwise>
					<xsl:value-of select="'csharp:GenerateGuid(@NodeId)'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template name="GetClassDefinition">
		<xsl:param name="AssumedClassType"/>
		<xsl:param name="ClassId"/>
		
		<xsl:variable name="UAClassDefinition">
			<xsl:call-template name="GetElementById">
				<xsl:with-param name="ID" select="$ClassId"/>
			</xsl:call-template>
		</xsl:variable>		
				
		<xsl:variable name="UAParentDefinition">
			<xsl:call-template name="GetElementById">
				<xsl:with-param name="ID" select="@Source"/>
			</xsl:call-template>
		</xsl:variable>		
		
		<xsl:variable name="UAAttributes">
			<xsl:call-template name="GetAttributeByReferenceType">
				<xsl:with-param name="Parent" select="$ClassId"/>
				<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
			</xsl:call-template>
		</xsl:variable>		

		<xsl:variable name="ClassType">
			<xsl:choose>
				<xsl:when test="$AssumedClassType!=''">
					<xsl:value-of select="$AssumedClassType"/>
				</xsl:when>
				<xsl:when test="name($UAClassDefinition/*[1])='UAObjectType'">
					<xsl:value-of select="'RoleClass'"/>
				</xsl:when>			
				<xsl:when test="name($UAClassDefinition/*[1])='UAReferenceType'">
					<xsl:value-of select="'InterfaceClass'"/>
				</xsl:when>
				<xsl:when test="name($UAClassDefinition/*[1])='UADataType'">
					<xsl:value-of select="'AttributeType'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name($UAClassDefinition/*[1])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
				
		<xsl:comment>TODO: wie wird der BrowseName abgebildet?</xsl:comment>
		<xsl:element name="{$ClassType}">
			<xsl:attribute name="Name"><xsl:value-of select="$UAClassDefinition//ua:DisplayName"/></xsl:attribute>
			<xsl:if test="$UAParentDefinition//ua:DisplayName">
				<xsl:attribute name="RefBaseClassPath" select="$UAParentDefinition//ua:DisplayName"/>
			</xsl:if>
			<xsl:if test="ua:Documentation">
				<Description><xsl:value-of select="ua:Documentation"/></Description>
			</xsl:if>
			<xsl:for-each select="$UAAttributes//ua:UAVariable">
				<Attribute>
					<xsl:variable name="AttributeDataType" select="@DataType"/>
					<xsl:attribute name="Name" select="ua:DisplayName"/>
					<xsl:attribute name="AttributeDataType">
						<xsl:choose>
							<xsl:when test="exslt:node-set($DataTypes)/*[@OPCAlias=$AttributeDataType]/@AML!=''">
								<xsl:value-of select="exslt:node-set($DataTypes)/*[@OPCAlias=$AttributeDataType]/@AML"/>
							</xsl:when>
							<xsl:when test="exslt:node-set($DataTypes)/*[@OPCNodeId=$AttributeDataType]/@AML!=''">
								<xsl:value-of select="exslt:node-set($DataTypes)/*[@OPCNodeId=$AttributeDataType]/@AML"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$AttributeDataType"/>
							</xsl:otherwise>
						</xsl:choose>					
					
					</xsl:attribute>
				</Attribute>
			</xsl:for-each>
			
			<!-- get all SubType descriptions -->
			<xsl:for-each select="$References/*/caex:Reference[@ReferenceType='HasSubtype' and @Source=$ClassId]">
				<xsl:call-template name="GetClassDefinition">
					<xsl:with-param name="ClassId" select="@Target"/>
					<xsl:with-param name="AssumedClassType" select="$AssumedClassType"/>
				</xsl:call-template>
			</xsl:for-each>			
		</xsl:element>
		
	</xsl:template>
	
<!-- *************************************************************
***
*** translation
***
************************************************************* -->
	
	<xsl:template match="ua:UANodeSet">
		<xsl:variable name="CAEXFileObject"> 
			<xsl:call-template name="GetAllObjectsByRefType">				
				<xsl:with-param name="RefType" select="'HasTypeDefinition'"/>
				<xsl:with-param name="RefId" select="'ns=1;i=1005'"/>
			</xsl:call-template>
		</xsl:variable>
				
		<xsl:variable name="Instances">
			<xsl:copy-of select="ua:UAObject"/>
		</xsl:variable>		
		
		<CAEXFile>
			
			<xsl:attribute name="SchemaVersion" select="'3.0'"/>
			
			<!--xsl:copy-of select="$LibraryTree"/-->
			
			<!-- TODO: generate -->
			<AdditionalInformation DocumentVersions="Recommendations" />
			<SuperiorStandardVersion>AutomationML 2.10</SuperiorStandardVersion>
			<SourceDocumentInformation OriginName="AutomationML Editor" OriginID="916578CA-FE0D-474E-A4FC-9E1719892369" OriginVersion="6.1.7.0" LastWritingDateTime="2023-11-13T13:51:54.1061533+01:00" OriginProjectID="unspecified" OriginProjectTitle="unspecified" OriginRelease="6.1.7.0" OriginVendor="AutomationML e.V." OriginVendorURL="www.AutomationML.org" />
	
			<!-- Generate AMLLibraries from collected data -->
			<xsl:variable name="AMLLibraries">				
				<xsl:for-each select="$LibraryTree//caex:Library[caex:Reference]">	
					<xsl:variable name="Reference" select="caex:Reference"/>
					<xsl:variable name="ClassType" select="@ClassType"/>
					<xsl:variable name="LibName">
						<xsl:value-of select="fn:replace(fn:replace(fn:replace(fn:replace(@Name, 'SystemUnitClassLib', ''), 'RoleClassLib', ''), 'InterfaceClassLib', ''), 'AttributeTypeLib', '')"/>
					</xsl:variable>

					<xsl:variable name="ListOfClasses">				
						<xsl:for-each select="$Reference">
							<xsl:call-template name="GetClassDefinition">
								<xsl:with-param name="ClassId" select="@Target"/>		
								<xsl:with-param name="AssumedClassType" select="$ClassType"/>					
							</xsl:call-template>
						</xsl:for-each>
					</xsl:variable>
			
					<xsl:variable name="Version">
						<xsl:call-template name="GetAttributeByDisplayName">
							<xsl:with-param name="Parent" select="ua:UAObject/@NodeId"/>
							<xsl:with-param name="DisplayName" select="'Version'"/>
							<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
						</xsl:call-template>
					</xsl:variable>
	
					<xsl:if test="$ListOfClasses/caex:SystemUnitClass">
						<SystemUnitClassLib>
							<xsl:attribute name="Name" select="concat($LibName,'SystemUnitClassLib')"/>		
							<Version>
								<xsl:choose>
									<xsl:when test="$Version//ua:Value/*"><xsl:value-of select="$Version//ua:Value/*"/></xsl:when>
									<xsl:otherwise>0.0.0</xsl:otherwise>
								</xsl:choose>
							</Version>
							<Description><xsl:value-of select="./ua:UAObject/ua:Documentation"/></Description>
			
							<xsl:copy-of select="$ListOfClasses/caex:SystemUnitClass"/>
						</SystemUnitClassLib>
					</xsl:if>
					<xsl:if test="$ListOfClasses/caex:RoleClass">
						<RoleClassLib>
							<xsl:attribute name="Name" select="concat($LibName,'RoleClassLib')"/>
							<Version>
								<xsl:choose>
									<xsl:when test="$Version//ua:Value/*"><xsl:value-of select="$Version//ua:Value/*"/></xsl:when>
									<xsl:otherwise>0.0.0</xsl:otherwise>
								</xsl:choose>
							</Version>
							<Description><xsl:value-of select="./ua:UAObject/ua:Documentation"/></Description>

							<Test>
								<xsl:copy-of select="$ListOfClasses/caex:RoleClass"/>							
							</Test>
						</RoleClassLib>
					</xsl:if>
					<xsl:if test="$ListOfClasses/caex:InterfaceClass">
						<InterfaceClassLib>
							<xsl:attribute name="Name" select="concat($LibName,'InterfaceClassLib')"/>
							<Version>
								<xsl:choose>
									<xsl:when test="$Version//ua:Value/*"><xsl:value-of select="$Version//ua:Value/*"/></xsl:when>
									<xsl:otherwise>0.0.0</xsl:otherwise>
								</xsl:choose>
							</Version>
							<Description><xsl:value-of select="./ua:UAObject/ua:Documentation"/></Description>

							<xsl:copy-of select="$ListOfClasses/caex:InterfaceClass"/>
						</InterfaceClassLib>
					</xsl:if>
					<xsl:if test="$ListOfClasses/caex:AttributeType">
						<AttributeTypeLib>
							<xsl:attribute name="Name" select="concat($LibName,'AttributeTypeLib')"/>
							<Version>
								<xsl:choose>
									<xsl:when test="$Version//ua:Value/*"><xsl:value-of select="$Version//ua:Value/*"/></xsl:when>
									<xsl:otherwise>0.0.0</xsl:otherwise>
								</xsl:choose>
							</Version>
							<Description><xsl:value-of select="./ua:UAObject/ua:Documentation"/></Description>

							<xsl:copy-of select="$ListOfClasses/caex:AttributeType"/>
						</AttributeTypeLib>				
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:copy-of select="$AMLLibraries"/>
			
			<!--NotYetTranslated>
				<xsl:for-each select="$UANodeSet//*[
					name()='UAObjectType' or 
					name()='UADataType' or 
					name()='UAReferenceType' or 
					name()='UAMethod' or
					name()='UAObject']">
					<xsl:variable name="ClassName" select="ua:DisplayName"/>
					<xsl:if test="not($AMLLibraries//*[@Name=$ClassName])">
						<xsl:element name="{name()}">
							<xsl:attribute name="Name"><xsl:value-of select="$ClassName"/></xsl:attribute>
						</xsl:element>
					</xsl:if>
				</xsl:for-each>
			</NotYetTranslated-->
			
			
		</CAEXFile>
	</xsl:template>
</xsl:stylesheet>
