<cfcomponent hint="gets routing numbers from Federal Reserve Financial Services ">
	<!--- create an instance variable for the routing numbers query --->
    <cfset this.qRoutingNumbers = QueryNew('routing_number, office_code, servicing_frb_number, record_type_code, change_date, new_routing_number, customer_name, address, city, state_code, zip_code, zip_code_extension, telephone_number, institution_status_code, data_view_code', 'varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar')/>
     
    <!--- Only get the data once per instance --->        
	<cfhttp url="http://www.fededirectory.frb.org/FedACHdir.txt" method="get" firstrowasheaders="no" throwonerror="yes" result="this.raw_routing_numbers" timeout="600">


	<!--- PUBLIC FUNCTIONS --->
	
    <!--- return all records --->
    <cffunction name="findAll" access="public" returntype="query" output="no" hint="return a query object of all routing numbers and information">
       	<cfset createDataSet() />
        
        <cfreturn this.qRoutingNumbers />
    </cffunction>

	<!--- return one record for requested routing number --->
	<cffunction name="findByRoutingNumber" access="public" returntype="query" output="no" hint="look up a routing number">
    	<cfargument name="routingNumber" type="numeric" required="yes"/>
		<cfset createDataSet() />
        
        <cfquery name="qRoutingNumber" dbtype="query">
        SELECT * 
        FROM this.qRoutingNumbers
        WHERE routing_number = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.routingNumber#"/>
        </cfquery>
        
        <cfreturn qRoutingNumber />
    </cffunction>

	<!--- PRIVATE fUNCTIONS --->
    
	<!--- build the this.qRoutingNumbers query object --->
    <cffunction name="createDataSet" access="private" output="no" hint="create the routing numbers query object">
		<cfset var routingInfo = ''/>
        <cfset var currentRow = 0 />
        
        <!--- check to see if query has already been created for this object's instance --->
		<cfif this.qRoutingNumbers.RecordCount EQ 0>
		
		<!--- loop through the file of routing numbers that was downloaded --->
        <cfloop list="#this.raw_routing_numbers.fileContent#" index="lineItem" delimiters="#Chr(13)##Chr(10)#">
	       <cfset currentRow = currentRow + 1 />
           <cfset QueryAddRow(this.qRoutingNumbers) />
           
		   <!--- return a parsed version of the current line --->
           <cfset routingInfo = createRecord(lineItem, parseRawLine())/>
           
		   <!--- Add the parsed line as a new record to the query object --->
		   <cfset QuerySetCell(this.qRoutingNumbers, 'routing_number', routingInfo.routing_number, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'office_code', routingInfo.office_code, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'servicing_frb_number', routingInfo.servicing_frb_number, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'record_type_code', routingInfo.record_type_code, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'change_date', routingInfo.change_date, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'new_routing_number', routingInfo.new_routing_number, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'customer_name', routingInfo.customer_name, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'address', routingInfo.address, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'city', routingInfo.city, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'state_code', routingInfo.state_code, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'zip_code', routingInfo.zip_code, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'zip_code_extension', routingInfo.zip_code_extension, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'telephone_number', routingInfo.telephone_number, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'institution_status_code', routingInfo.institution_status_code, currentRow) />
           <cfset QuerySetCell(this.qRoutingNumbers, 'data_view_code', routingInfo.data_view_code, currentRow) />   
        </cfloop>
        </cfif> 
    </cffunction>

    <!--- parse a single line  --->
    <cffunction name="createRecord" access="private" returntype="struct" output="no" hint="parse out routing number and information from a line in the file">
		<cfargument name="rawLine" type="string" required="yes"/>
        <cfargument name="parser" type="array" required="yes"/>
        
        <cfset var startColumn = 1 />
        <cfset var dataSet = StructNew() />
        
        <!--- loop through the parser rules and parse out routing number and corresponding information --->
        <cfloop index="i" from="1" to="#ArrayLen(parser)#" step="1">
        	<cfset dataset[parser[i]['name']] = Trim(Mid(rawLine, startColumn, parser[i]['columns'])) />          
  			<!--- set the positing of the starting column for the next field --->
			<cfset startColumn = startColumn + parser[i]['columns'] />
        </cfloop>
        
        <cfreturn dataSet />		
    </cffunction>

	<!--- the rules for parsing a line --->
	<cffunction name="parseRawLine" access="private" returntype="array" output="no" hint="a parser for parsing out a line of raw text that contains routing number and information">
		<!--- parsing rules for each column --->
		<cfset var parser = ArrayNew(1)/>
        
        <cfset parser[1]['name'] = 'routing_number'/>
        <cfset parser[1]['columns'] = 9/>
        
        <cfset parser[2]['name'] = 'office_code'/>
        <cfset parser[2]['columns'] = 1/>
        
        <cfset parser[3]['name'] = 'servicing_frb_number'/>
        <cfset parser[3]['columns'] = 9/>
        
        <cfset parser[4]['name'] = 'record_type_code'/>
        <cfset parser[4]['columns'] = 1/>
        
        <cfset parser[5]['name'] = 'change_date'/>
        <cfset parser[5]['columns'] = 6/>
        
        <cfset parser[6]['name'] = 'new_routing_number'/>
        <cfset parser[6]['columns'] = 9/>
        
        <cfset parser[7]['name'] = 'customer_name'/>
        <cfset parser[7]['columns'] = 36/>
        
        <cfset parser[8]['name'] = 'address'/>
        <cfset parser[8]['columns'] = 36/>
        
        <cfset parser[9]['name'] = 'city'/>
        <cfset parser[9]['columns'] = 20/>
        
        <cfset parser[10]['name'] = 'state_code'/>
        <cfset parser[10]['columns'] = 2/>
        
        <cfset parser[11]['name'] = 'zip_code'/>
        <cfset parser[11]['columns'] = 5/>
        
        <cfset parser[12]['name'] = 'zip_code_extension'/>
        <cfset parser[12]['columns'] = 4/>
        
        <cfset parser[13]['name'] = 'telephone_number'/>
        <cfset parser[13]['columns'] = 10/>
        
        <cfset parser[14]['name'] = 'institution_status_code'/>
        <cfset parser[14]['columns'] = 1/>
        
        <cfset parser[15]['name'] = 'data_view_code'/>
        <cfset parser[15]['columns'] = 1/>
        
        <cfreturn parser/>
    </cffunction>
<!--- 
Definitions for parsing out routing numbers
http://www.fededirectory.frb.org/format_ACH.cfm
 --->
</cfcomponent>