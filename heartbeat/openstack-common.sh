OCF_RESKEY_clouds_yaml_default="$HOME/.config/openstack/clouds.yaml"
OCF_RESKEY_openstackcli_default="/usr/bin/openstack"
OCF_RESKEY_insecure_default="false"

: ${OCF_RESKEY_clouds_yaml=${OCF_RESKEY_clouds_yaml_default}}
: ${OCF_RESKEY_openstackcli=${OCF_RESKEY_openstackcli_default}}
: ${OCF_RESKEY_insecure=${OCF_RESKEY_insecure_default}}

if ocf_is_true "${OCF_RESKEY_insecure}"; then
	OCF_RESKEY_openstackcli="${OCF_RESKEY_openstackcli} --insecure"
fi

common_meta_data() {
	cat <<END

<parameter name="clouds_yaml" required="0">
<longdesc lang="en">
Openstack clouds.yaml config file.
</longdesc>
<shortdesc lang="en">clouds.yaml config file</shortdesc>
<content type="string" default="${OCF_RESKEY_clouds_yaml_default}" />
</parameter>

<parameter name="cloud" required="0">
<longdesc lang="en">
Openstack cloud (from ~/.config/openstack/clouds.yaml).
</longdesc>
<shortdesc lang="en">Cloud from clouds.yaml</shortdesc>
<content type="string" />
</parameter>

<parameter name="openrc" required="0">
<longdesc lang="en">
Openstack credentials as openrc file from api_access/openrc.
</longdesc>
<shortdesc lang="en">openrc file</shortdesc>
<content type="string" />
</parameter>

<parameter name="auth_url" required="0">
<longdesc lang="en">
Keystone Auth URL
</longdesc>
<shortdesc lang="en">Keystone Auth URL</shortdesc>
<content type="string" />
</parameter>

<parameter name="username" required="0">
<longdesc lang="en">
Username.
</longdesc>
<shortdesc lang="en">Username</shortdesc>
<content type="string" />
</parameter>

<parameter name="password" required="0">
<longdesc lang="en">
Password.
</longdesc>
<shortdesc lang="en">Password</shortdesc>
<content type="string" />
</parameter>

<parameter name="project_name" required="0">
<longdesc lang="en">
Keystone Project.
</longdesc>
<shortdesc lang="en">Keystone Project</shortdesc>
<content type="string" />
</parameter>

<parameter name="user_domain_name" required="0">
<longdesc lang="en">
Keystone User Domain Name.
</longdesc>
<shortdesc lang="en">Keystone User Domain Name</shortdesc>
<content type="string" />
</parameter>

<parameter name="project_domain_name" required="0">
<longdesc lang="en">
Keystone Project Domain Name.
</longdesc>
<shortdesc lang="en">Keystone Project Domain Name</shortdesc>
<content type="string" />
</parameter>

<parameter name="openstackcli">
<longdesc lang="en">
Path to command line tools for openstack.
</longdesc>
<shortdesc lang="en">Path to Openstack CLI tool</shortdesc>
<content type="string" default="${OCF_RESKEY_openstackcli_default}" />
</parameter>

<parameter name="insecure">
<longdesc lang="en">
Allow insecure connections
</longdesc>
<shortdesc lang="en">Allow insecure connections</shortdesc>
<content type="boolean" default="${OCF_RESKEY_insecure_default}" />
</parameter>
END
}

get_config() {
	if [ -n "$OCF_RESKEY_clouds_yaml" ]; then
		 if [ ! -f "$OCF_RESKEY_clouds_yaml" ]; then
			ocf_exit_reason "$OCF_RESKEY_clouds_yaml does not exist"
			return $OCF_ERR_CONFIGURED
		 fi
		 if [ -z "$OCF_RESKEY_cloud" ]; then
			ocf_exit_reason "cloud: $OCF_RESKEY_cloud not found in $OCF_RESKEY_clouds_yaml"
			return $OCF_ERR_CONFIGURED
		 fi
		OCF_RESKEY_openstackcli="${OCF_RESKEY_openstackcli} --os-cloud $OCF_RESKEY_cloud"
	elif [ -n "$OCF_RESKEY_openrc" ]; then
		if [ ! -f "$OCF_RESKEY_openrc" ]; then
			ocf_exit_reason "$OCF_RESKEY_openrc does not exist"
			return $OCF_ERR_CONFIGURED
		fi
		. $OCF_RESKEY_openrc
	else
		if [ -z "$OCF_RESKEY_auth_url" ]; then
			ocf_exit_reason "auth_url not set"
			return $OCF_ERR_CONFIGURED
		fi
		if [ -z "$OCF_RESKEY_username" ]; then
			ocf_exit_reason "username not set"
			return $OCF_ERR_CONFIGURED
		fi
		if [ -z "$OCF_RESKEY_password" ]; then
			ocf_exit_reason "password not set"
			return $OCF_ERR_CONFIGURED
		fi
		if [ -z "$OCF_RESKEY_project_name" ]; then
			ocf_exit_reason "project_name not set"
			return $OCF_ERR_CONFIGURED
		fi
		if [ -z "$OCF_RESKEY_user_domain_name" ]; then
			ocf_exit_reason "user_domain_name not set"
			return $OCF_ERR_CONFIGURED
		fi
		if [ -z "$OCF_RESKEY_project_domain_name" ]; then
			ocf_exit_reason " not set"
			return $OCF_ERR_CONFIGURED
		fi

		OCF_RESKEY_openstackcli="${OCF_RESKEY_openstackcli} --os-auth-url $OCF_RESKEY_auth_url"
		OCF_RESKEY_openstackcli="${OCF_RESKEY_openstackcli} --os-username $OCF_RESKEY_username"
		OCF_RESKEY_openstackcli="${OCF_RESKEY_openstackcli} --os-password $OCF_RESKEY_password"
		OCF_RESKEY_openstackcli="${OCF_RESKEY_openstackcli} --os-project-name $OCF_RESKEY_project_name"
		OCF_RESKEY_openstackcli="${OCF_RESKEY_openstackcli} --os-user-domain-name $OCF_RESKEY_user_domain_name"
		OCF_RESKEY_openstackcli="${OCF_RESKEY_openstackcli} --os-project-domain-name $OCF_RESKEY_project_domain_name"
	fi
}