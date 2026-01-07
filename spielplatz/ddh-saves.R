#########################################################################################################
########################### SAVE DATASETS FOR THE DEVELOPMENT DATA HUB ##################################
#########################################################################################################

### lets save the ctf dynamic and static scores as well as db variables

readr::write_csv(closeness_to_frontier_dynamic, "spielplatz/ddh_data/ctf_dynamic.csv")

readr::write_csv(closeness_to_frontier_static, "spielplatz/ddh_data/ctf_static.csv")

readr::write_csv(db_variables_final, "spielplatz/ddh_data/db_variables.csv")