#
# liquibase_wrapper.sh
#
#

export usage="./liquibase_wrapper.sh -a <app_name> -c <context> -s <schema> -t <tag>"

while [ "$1" != "" ]; do
	echo "$1"
    	case $1 in
        	-a | --app ) 	shift
				export app=$1
				echo $app
                                ;;
        	-c | --context )   	shift
				export context=$1
				echo "$context"
                                ;;
        	-s | --schema ) shift
				export schema=$1
				echo "$schema"
                                ;;
		-t | --tag ) 	shift
				export tag=$1
				echo "$tag"
				;;

    	esac
	shift

done

if [ -z $app ] || [ -z $context ] || [ -z $schema ] ; then
	echo "$usage"
	exit 1
fi


echo "app:$app"
echo "context:$context"
echo "schema:$schema"
echo "tag:$tag"


export jar=$LIQUI_HOME/liquibase.jar
export conf=$LIQUI_WRAP_HOME/conf/${app}/${context}/${schema}/liquibase.properties
export change_log_file=$LIQUI_WRAP_HOME/changesets/${app}/${schema}/master-${schema}.xml
export data_doc=$LIQUI_WRAP_HOME/data/

if [ ! -f $conf ] ; then
	echo "$conf not found"
	exit 1
fi

if [ ! -f $change_log_file ] ; then
	echo "$change_log_file not found"
	exit 1
fi

echo "running update"	
java -jar $jar --defaultsFile=$conf  \
	--changeLogFile=$change_log_file \
	update	
if [ ! -z $tag ] ; then
	echo "tagging for rollback $tag"
	java -jar $jar --defaultsFile=$conf  \
	--changeLogFile=$change_log_file \
		tag $tag
fi

echo "running report"
java -jar $jar --defaultsFile=$conf  \
	--changeLogFile=$change_log_file \
	dbDoc $data_doc	
