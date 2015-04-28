Working with bank routing numbers? This CFC's findAll() function loads a 3.5MB text file of over 20,000 routing numbers and returns a query object.

The best use for the findAll() function is to loop through the query object it returns and insert each record into a database table (i.e. nightly scheduled task). The routing numbers in the text file can change nightly. It also takes a few seconds to downlaod the information, parse it, and create the query object. Thus, placing the data in a database and working with that makes the most sense from a performance perspective.

Example
<cfinvoke component="RoutingNumbers" method="findAll" returnvariable="routing_numbers"/>

Column names: routing_number, office_code, servicing_frb_number, record_type_code, change_date, new_routing_number, customer_name, address, city, state_code, zip_code, zip_code_extension, telephone_number, institution_status_code, data_view_code

An explanation for each one of the provided columns can be found at http://www.fededirectory.frb.org/format_ACH.cfm