<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:ua="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd"
	xmlns:uaTypes="http://opcfoundation.org/UA/2008/02/Types.xsd"
	xmlns:exslt="http://exslt.org/common"
	exclude-result-prefixes="xsi xsl ua uaTypes xsd exslt">
	<!--xmlns:csharp="http://csharp.org"-->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
			
    <!--msxsl:script language="C#" implements-prefix="csharp">
		<msxsl:using namespace="System.Security.Cryptography" />
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
	</msxsl:script-->
    
   	<xsl:function name="exslt:node-set">
		<xsl:param name="rtf"/>
		<xsl:sequence select="$rtf"/>
	</xsl:function>
	<!--xsl:include href="DatatypeTranslation.xslt"/-->

	<!-- Add bi-directional references -->
	<xsl:variable name="UANodeSet">
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
								<xsl:if test="not(@IsForward=false())">
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
							<!-- do not add twice -->
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
	</xsl:variable>
	
	<xsl:variable name="Libraries">
		<xsl:for-each select="exslt:node-set($UANodeSet)//ua:NamespaceUris/ua:Uri">
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
		
		<xsl:for-each select="exslt:node-set($Parent)//ua:Reference[@ReferenceType=$ReferenceType]">
			<xsl:variable name="ComponentId" select="text()"/>
			<xsl:variable name="TargetObject">
				<xsl:copy-of select="exslt:node-set($UANodeSet)//*[@NodeId=$ComponentId]"/>
			</xsl:variable>
			<xsl:if test="exslt:node-set($TargetObject)//ua:DisplayName=$DisplayName">
				<xsl:copy-of select="exslt:node-set($TargetObject)"/>
			</xsl:if>
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
		
		<xsl:for-each select="exslt:node-set($Parent)//ua:Reference[@ReferenceType=$ReferenceType]">
			<xsl:variable name="ComponentId" select="text()"/>
			<xsl:variable name="TargetObject">
				<xsl:copy-of select="exslt:node-set($UANodeSet)//*[@NodeId=$ComponentId]"/>
			</xsl:variable>
			<xsl:copy-of select="exslt:node-set($TargetObject)"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="GetAttributeByTypeDefinition">
		<xsl:param name="Parent"/>
		<xsl:param name="TypeDefinition"/>
		<xsl:param name="ReferenceType"/>
		
		<xsl:variable name="AttributeByReferenceType">
			<xsl:call-template name="GetAttributeByReferenceType">
				<xsl:with-param name="Parent" select="$Parent"/>
				<xsl:with-param name="ReferenceType" select="$ReferenceType"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:for-each select="exslt:node-set($AttributeByReferenceType)">
			<xsl:if test="//ua:Reference[@ReferenceType='HasTypeDefinition'] = $TypeDefinition">
				<xsl:copy-of select="."/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="GetAttributeValueByTypeDefinition">
		<xsl:param name="Parent"/>
		<xsl:param name="TypeDefinition"/>
		<xsl:param name="ReferenceType"/>
		
		<xsl:variable name="Attribute">
			<xsl:call-template name="GetAttributeByTypeDefinition">
				<xsl:with-param name="Parent" select="$Parent"/>
				<xsl:with-param name="TypeDefinition" select="$TypeDefinition"/>
				<xsl:with-param name="ReferenceType" select="$ReferenceType"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:copy-of select="exslt:node-set($Attribute)//ua:Value/uaTypes:String/*/."/>
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
				<xsl:when test="exslt:node-set($Id)/*/ua:Value/uaTypes:String!=''"><xsl:value-of select="exslt:node-set($Id)/*/ua:Value/uaTypes:String"/></xsl:when>
				<xsl:otherwise>TODO:GenerateGuid<!--xsl:value-of select="'csharp:GenerateGuid(@NodeId)'"/--></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template name="CreateBody">		
		<xsl:attribute name="Name"><xsl:value-of select="@BrowseName"/></xsl:attribute>
		<xsl:variable name="ID" select="@NodeId"/>
		<xsl:call-template name="CreateAmlId"/>
		
		<xsl:variable name="ExternalInterfaces">
			<xsl:call-template name="GetAttributeByReferenceType">
				<xsl:with-param name="Parent" select="."/>
				<xsl:with-param name="ReferenceType" select="'HasComponent'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="Attributes">
			<xsl:call-template name="GetAttributeByReferenceType">
				<xsl:with-param name="Parent" select="."/>
				<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="RoleReference">
			<xsl:call-template name="GetAttributeByReferenceType">
				<xsl:with-param name="Parent" select="."/>
				<xsl:with-param name="ReferenceType" select="'HasAMLRoleReference'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="InternalElements">
			<xsl:call-template name="GetAttributeByReferenceType">
				<xsl:with-param name="Parent" select="."/>
				<xsl:with-param name="ReferenceType" select="'HasComponent'"/>
			</xsl:call-template>
		</xsl:variable>
				
		<xsl:for-each select="exslt:node-set($Attributes)/ua:UAVariable">
			<xsl:if test="@BrowseName!='ID'">
			<Attribute>
				<xsl:attribute name="Name"><xsl:value-of select="@BrowseName"/></xsl:attribute>
				<xsl:if test="ua:Value/uaTypes:String">
					<xsl:value-of select="ua:Value/uaTypes:String"/>
				</xsl:if>
			</Attribute>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="exslt:node-set($InternalElements)/ua:UAObject">
			<xsl:if test="ua:References/ua:Reference[@ReferenceType='HasComponent' and @IsForward=false() and text()=$ID]">
				<InternalElement>
					<xsl:call-template name="CreateBody"/>
				</InternalElement>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="exslt:node-set($ExternalInterfaces)/ua:UAObject">
			<xsl:if test="ua:References/ua:Reference[@ReferenceType='HasComponent' and @IsForward=false() and text()=$ID]">
				<ExternalInterface>
					<xsl:attribute name="Name"><xsl:value-of select="@BrowseName"/></xsl:attribute>				
					<xsl:call-template name="CreateAmlId"/>			
				</ExternalInterface>
			</xsl:if>
		</xsl:for-each>
		<!-- TODO: Complete RefRoleClassPath -->
		<xsl:for-each select="exslt:node-set($RoleReference)/*">
			<xsl:if test="ua:References/ua:Reference[@ReferenceType='HasAMLRoleReference' and @IsForward=false() and text()=$ID]">
			<SupportedRoleClass>
				<xsl:attribute name="RefRoleClassPath"><xsl:value-of select="@BrowseName"/></xsl:attribute>
			</SupportedRoleClass>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="ua:UANodeSet">		
		<xsl:comment>
			CAEXFile
			=============
			TODOs:
				- are '{GUID}' and 'GUID' equal? -> done
				- get correct NS id for http://opcfoundation.org/UA/AML/
				- what is the marker for the FileName/ SchemaVersion/ etc.-> done (@BrowseName)
				- How to handle forward and backward references? (and missing forward or backward references) -> done (generate both directions)
				- How to handle dublicate NodeIds? -> CAEXFile_WriterHeader -> done (not allowed)
			</xsl:comment>
		<CAEXFile>		
			<xsl:variable name="CAEXFileObject" select="//ua:UAObject//ua:Reference[@ReferenceType='HasTypeDefinition'  and text()='ns=1;i=1005']/../.."/>

			<xsl:if test="$CAEXFileObject">
				<xsl:attribute name="FileName">
					<xsl:call-template name="GetAttributeValueByDisplayName">
						<xsl:with-param name="Parent"><xsl:copy-of select="exslt:node-set($CAEXFileObject)"/></xsl:with-param>
						<xsl:with-param name="DisplayName" select="'FileName'"/>
						<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
					</xsl:call-template>
				</xsl:attribute>	
				
				<xsl:attribute name="SchemaVersion">
					<xsl:call-template name="GetAttributeValueByDisplayName">
						<xsl:with-param name="Parent"><xsl:copy-of select="exslt:node-set($CAEXFileObject)"/></xsl:with-param>
						<xsl:with-param name="DisplayName" select="'SchemaVersion'"/>
						<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
					</xsl:call-template>
				</xsl:attribute>
			</xsl:if>

			<xsl:variable name="MaybeAdditionalInformation">
				<xsl:call-template name="GetAttributeByReferenceType">
					<xsl:with-param name="Parent"><xsl:copy-of select="exslt:node-set($CAEXFileObject)"/></xsl:with-param>
					<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
				</xsl:call-template>
			</xsl:variable>
					
			<xsl:for-each select="exslt:node-set($MaybeAdditionalInformation)//ua:Value/uaTypes:String/AdditionalInformation">
				<xsl:copy-of select="."/>
			</xsl:for-each>
			
			<xsl:comment>
			InstanceHierarchy
			=============
			TODOs:
			- distingish between Internal Elements and ExternalInterfaces
			</xsl:comment>

			<xsl:for-each select="exslt:node-set($Libraries)//Library">
				<xsl:variable name="Id" select="@Id"/>
				
				<xsl:variable name="MaybeInternalElement">
					<xsl:for-each select="exslt:node-set($UANodeSet)//ua:UAObject[starts-with(@NodeId, concat('ns=',$Id))]">
						<xsl:choose>
							<xsl:when test="ua:References/ua:Reference/@ReferenceType='Organizes'">
								<!--ignore folder types-->
							</xsl:when>
							<xsl:when test="@BrowseName='InterfaceClassLibs'">
								<!--ignore folder types-->
							</xsl:when>
							<xsl:when test="@BrowseName='RoleClassLibs'">
								<!--ignore folder types-->
							</xsl:when>
							<xsl:when test="@BrowseName='SystemUnitClassLibs'">
								<!--ignore folder types-->
							</xsl:when>
							<xsl:when test="@BrowseName='InstanceHierarchies'">
								<!--ignore folder types-->
							</xsl:when>
							<!-- only copy sub components if the parent is the InstanceHierarchy -->
							<xsl:when test="ua:References/ua:Reference[@ReferenceType='HasComponent' and @IsForward=false()]">
								<xsl:for-each select="ua:References/ua:Reference[@ReferenceType='HasComponent']">
									<xsl:variable name="RefId"><xsl:value-of select="."/></xsl:variable>
									<!-- if we have a child of InstanceHierarchy then copy it -->
									<xsl:if test="exslt:node-set($UANodeSet)//*[@NodeId=$RefId]/ua:References/ua:Reference[@ReferenceType='Organizes' and @IsForward=false() and text()='ns=1;i=5005']">
										<xsl:copy-of select="../.."/>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<!-- all other criterias for non InternalElements -->
							<!--xsl:when test=""></xsl:when-->
							<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
							
				<xsl:if test="$MaybeInternalElement!=''">
					<InstanceHierarchy>
						<xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>
						<xsl:if test="exslt:node-set($UANodeSet)//ua:UAObject[@NodeId=concat('ns=', $Id, ';s=Library')]">
							<Version>
								<xsl:call-template name="GetAttributeValueByDisplayName">
									<xsl:with-param name="Parent" select="exslt:node-set($UANodeSet)//ua:UAObject[@NodeId=concat('ns=', $Id, ';s=Library')]"/>
									<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
									<xsl:with-param name="DisplayName" select="'Version'"/>
								</xsl:call-template>								
							</Version>
						</xsl:if>
						<xsl:for-each select="exslt:node-set($MaybeInternalElement)/ua:UAObject">
							<InternalElement>
								<xsl:call-template name="CreateBody"/>
							</InternalElement>
						</xsl:for-each>
					</InstanceHierarchy>
				</xsl:if>
			</xsl:for-each>

			<xsl:if test="ua:UAObjectType">				
				<xsl:comment>
				Libraries
				=============
				TODOs:
				- Distinction between SystemUnitClass, RoleClass, InterfaceClass
				- Handle class hierarchies
				</xsl:comment>
				<xsl:for-each select="exslt:node-set($Libraries)//Library">
					<xsl:variable name="Id" select="@Id"/>
					<xsl:if test="exslt:node-set($UANodeSet)//ua:UAObjectType[starts-with(@NodeId, concat('ns=',$Id))]">
						<SystemUnitClassLib>
							<xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>
							<xsl:if test="exslt:node-set($UANodeSet)//ua:UAObject[@NodeId=concat('ns=', $Id, ';s=Library')]">
								<Version>
									<xsl:call-template name="GetAttributeValueByDisplayName">
										<xsl:with-param name="Parent" select="exslt:node-set($UANodeSet)//ua:UAObject[@NodeId=concat('ns=', $Id, ';s=Library')]"/>
										<xsl:with-param name="ReferenceType" select="'HasProperty'"/>
										<xsl:with-param name="DisplayName" select="'Version'"/>
									</xsl:call-template>								
								</Version>
							</xsl:if>
							<xsl:for-each select="exslt:node-set($UANodeSet)//ua:UAObjectType[starts-with(@NodeId, concat('ns=',$Id))]">
								<SystemUnitClass>
									<xsl:call-template name="CreateBody"/>
								</SystemUnitClass>
							</xsl:for-each>
						</SystemUnitClassLib>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</CAEXFile>
	</xsl:template>

</xsl:stylesheet>
