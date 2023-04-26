<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	xmlns:ua="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd" 
	xmlns:uaTypes="http://opcfoundation.org/UA/2008/02/Types.xsd" 
	xmlns:exslt="http://exslt.org/common" 
	xmlns:csharp="http://csharp.org" 
	exclude-result-prefixes="xsi xsl ua uaTypes xsd exslt">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="DefaultFileName">TODO: unspecified FileName</xsl:variable>
	<xsl:variable name="DefaultSchemaVersion">3.0</xsl:variable>
	<!--TODO:must be resolved as javascript-->
	<!-- xmlns:js="urn:custom-javascript"
    exclude-result-prefixes="custom js"

	 <custom:script language="Javascript" implements-prefix="js">
        <![CDATA[
        function GenerateGuid (string input) {
            ... java code for GUID ...
        }
    ]]>
    </custom:script>

	-->
	<msxsl:script language="C#" implements-prefix="csharp">
	<msxsl:using namespace="System.Security.Cryptography"/>
	<![CDATA[   
			public string GenerateGuid(string input)
			{
				Guid guid = Guid.Empty;
				using (MD5 md5 = MD5.Create())
				{
					byte[] hash = md5.ComputeHash(Encoding.Default.GetBytes(input));
					guid = new Guid(hash);
				}
				return guid.ToString();
			}
		]]>
	</msxsl:script>
	<!--
Laut Microsoft muss man die Funktionalität mit „XsltSettings.EnableScript“ aktivieren, bevor man XslTransform startet:
https://docs.microsoft.com/de-de/dotnet/api/system.xml.xsl.xsltsettings.enablescript?view=net-5.0

	-->
	<xsl:function name="exslt:node-set">
		<xsl:param name="rtf"/>
		<xsl:sequence select="$rtf"/>
	</xsl:function>
	<!--xsl:include href="DatatypeTranslation.xslt"/-->
	<!-- Add bi-directional references -->
	<!--xsl:variable name="UANodeSet">
		<xsl:for-each select="ua:UANodeSet">
			<xsl:copy>
				<xsl:copy-of select="ua:NamespaceUris"/>
				<xsl:copy-of select="ua:Models"/>
				<xsl:copy-of select="ua:Aliases"/>
				<xsl:for-each select="*[local-name()!='NamespaceUris' and local-name()!='Models' and local-name()!='Aliases']">
					<xsl:variable name="NodeId" select="@NodeId"/>
					<xsl:variable name="AdditionalReferences">
						<xsl:for-each select="../*/ua:References/ua:Reference[text()=$NodeId]">
							<xsl:copy>
								<xsl:copy-of select="@*[local-name()!='IsForward']"/>
								<xsl:if test="@IsForward='False' or @IsForward=false()">
									<xsl:attribute name="IsForward" select="false()"/>
								</xsl:if>
								<xsl:value-of select="../../@NodeId"/>
							</xsl:copy>
						</xsl:for-each>
					</xsl:variable>
					<xsl:copy>
						<xsl:copy-of select="@*"/>
						<xsl:copy-of select="*[local-name()!='References']"/>
						<xsl:variable name="LocalReferences">
							<xsl:copy-of select="ua:References/ua:Reference"/>
						</xsl:variable>
						<xsl:for-each select="ua:References">
							<xsl:copy>
								<xsl:copy-of select="exslt:node-set($LocalReferences)"/>
								<do not add twice>
								<xsl:for-each select="exslt:node-set($AdditionalReferences)/ua:Reference">
									<xsl:variable name="AddRefId" select="text()"/>
									<xsl:if test="count(exslt:node-set($LocalReferences)//ua:Reference[text()=$AddRefId])=0">
										<xsl:copy-of select="."/>
									</xsl:if>
								</xsl:for-each>
							</xsl:copy>
						</xsl:for-each>
					</xsl:copy>
				</xsl:for-each>
			</xsl:copy>
		</xsl:for-each>
	</xsl:variable-->
	<!-- collect all references -->
	<xsl:variable name="References">
		<References>
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
		</References>
	</xsl:variable>
	<!-- collect all libraries -->
	<xsl:variable name="Libraries">
		<xsl:for-each select="exslt:node-set(ua:UANodeSet)//ua:NamespaceUris/ua:Uri">
			<Library>
				<xsl:attribute name="Name">
					<xsl:call-template name="GetSubstringAfterLast">
						<xsl:with-param name="input" select="."/>
						<xsl:with-param name="pattern" select="'/'"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="Id">
					<xsl:value-of select="position()"/>
				</xsl:attribute>
			</Library>
		</xsl:for-each>
	</xsl:variable>
	<!-- complete UANodeSet -->
	<xsl:variable name="UANodeSet">
		<xsl:copy-of select="ua:UANodeSet"/>
	</xsl:variable>
	<!-- .........................................................................
		Unknown Elements: Ignore
	.........................................................................-->
	<xsl:template match="text()"/>
	<xsl:template name="GetAttributeValue">
		<xsl:param name="NodeId"/>
		<xsl:value-of select="//ua:UAVariable[@NodeId=$NodeId]/ua:Value/uaTypes:String"/>
	</xsl:template>
	<xsl:template name="GetAttributeByDisplayName">
		<xsl:param name="Parent"/>
		<xsl:param name="DisplayName"/>
		<xsl:param name="ReferenceType"/>
		<xsl:for-each select="$References/*/Reference[@ReferenceType=$ReferenceType and @Source=$Parent]">
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
		<xsl:for-each select="$References/*/Reference[@ReferenceType=$ReferenceType and @Source=$Parent]">
			<xsl:variable name="Target" select="@Target"/>
			<xsl:copy-of select="$UANodeSet//*[@NodeId=$Target]"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="GetAllObjectsWithTypeDefinition">
		<xsl:param name="TypeDefinition"/>
		<xsl:for-each select="$References//*[@ReferenceType='HasTypeDefinition' and @Target=$TypeDefinition]">
			<xsl:variable name="Source" select="@Source"/>
			<xsl:copy-of select="$UANodeSet//*[@NodeId=$Source]"/>
		</xsl:for-each>
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
	<!-- .........................................................................
		Translate UANodeSet
	.........................................................................-->
	<xsl:template match="ua:UANodeSet">
		<xsl:comment>
			1. Find CAEXFile element
			2. Find FileName and SchemaVersion
			2. Find Instance Hierarchy, Libraries			
			3. Find AML Version
			4. Find SupperiorStandardVersion or specific AdditionalInformation
		</xsl:comment>
		<CAEXFile>
			<xsl:variable name="FileInfo">
				<xsl:call-template name="GetAllObjectsWithTypeDefinition">
					<xsl:with-param name="TypeDefinition" select="'ns=1;i=1005'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="FileName">
				<xsl:call-template name="GetAttributeValueByDisplayName">
					<xsl:with-param name="Parent" select="$FileInfo/ua:UAObject/@NodeId"/>
					<xsl:with-param name="DisplayName" select="'FileName'"/>
					<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="SchemaVersion">
				<xsl:call-template name="GetAttributeValueByDisplayName">
					<xsl:with-param name="Parent" select="$FileInfo/ua:UAObject/@NodeId"/>
					<xsl:with-param name="DisplayName" select="'SchemaVersion'"/>
					<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:attribute name="FileName">
				<xsl:choose>
					<xsl:when test="$FileName">
						<xsl:value-of select="$FileName"/>
					</xsl:when>
					<xsl:when test="$FileInfo/ua:UAObject/ua:DisplayName">
						<xsl:value-of select="$FileInfo/ua:UAObject/ua:DisplayName"/>
					</xsl:when>
					<xsl:when test="$FileInfo/ua:UAObject/@BrowseName">
						<xsl:value-of select="$FileInfo/ua:UAObject/@BrowseName"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$DefaultFileName"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="SchemaVersion">
				<xsl:choose>
					<xsl:when test="$SchemaVersion">
						<xsl:value-of select="$SchemaVersion"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$DefaultSchemaVersion"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="$SchemaVersion='3.0'">
				<xsl:comment>TODO: SupperiorStandardVersion and Co. needed to load</xsl:comment>
			</xsl:if>
			<xsl:for-each select="$References/*/Reference[@Source=$FileInfo/ua:UAObject/@NodeId]">
				<xsl:choose>
					<xsl:when test="@ReferenceType='HasTypeDefinition'">
						<!--ignore-->
					</xsl:when>
					<xsl:when test="@ReferenceType='HasProperty'">
						<xsl:comment>TODO: check if this is only FileName and SchemaVersion</xsl:comment>
						
						<xsl:call-template name="GetTargetElement">
							<xsl:with-param name="Reference" select="."/>
						</xsl:call-template>
						
					</xsl:when>
					<xsl:when test="@ReferenceType='HasComponent'">
						<xsl:comment>TODO: check if this is only FileName and SchemaVersion</xsl:comment>
						<xsl:comment>TODO: otherwise check if Additional Information</xsl:comment>
						<xsl:comment>TODO: otherwise interprete as Additional Information</xsl:comment>
					</xsl:when>
					<xsl:otherwise>
						<xsl:comment>
							<xsl:value-of select="concat('Unknown reference: ´', @Source, '´ ', @ReferenceType, ' ´', @Target), '´'"/>
						</xsl:comment>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:for-each select="$References/*/Reference[@Target=$FileInfo/ua:UAObject/@NodeId]">
				<xsl:choose>
					<xsl:when test="@ReferenceType='Organizes' and @Target='ns=1;i=5006'"/>
					<xsl:otherwise>
						<xsl:comment>
							<xsl:value-of select="concat('Unknown reference: ´', @Source, '´ ', @ReferenceType, ' ´', @Target), '´'"/>
						</xsl:comment>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<!--xsl:call-template name="GetAttributeByDisplayName">
				<xsl:with-param name="Parent" select="$FileInfo/ua:UAObject/@NodeId"/>
				<xsl:with-param name="DisplayName" select="'SchemaVersion'"/>
				<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
			</xsl:call-template-->
		</CAEXFile>
	</xsl:template>
</xsl:stylesheet>