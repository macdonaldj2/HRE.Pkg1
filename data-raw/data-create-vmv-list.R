#-------------------------------------------------------------------------------
# CODE DATASET OF VMVS IN PYLTM -- pulled from envirodat directly
# - excludes organics, and some other non-useful VMVs
# - add paramCODE, Analysis_Split from ecwqData::vmv_xref
# - add information from ecwqData::paramCODE_info ???
#-------------------------------------------------------------------------------

#get organics to exclude
organics_gr <- c("ACIDS", "AROMATIC HYDROCARBONS",
                 "HYDROCARBONS, AROMATIC", "HYDROCARBONS, HALOGENATED ALIPHATIC",
                 "HYDROCARBONS, HALOGENATED AROMATIC", "HYDROCARBONS, HALOGENATED MONOAROMATIC",
                 "HYDROCARBONS, SUBSTITUTED AROMATIC", "NAPHTHENIC ACIDS",
                 "POLYNUCLEAR AROMATIC HYDROCARBON", "SURROGATE", "OTHER ORGANICS")

vmv_query <- paste0(
  "select distinct vmv.vmv_code, vmv.method_code, vmv.unit_code, v.variable_code, ",
  "v.variable_name, v.variable_group from pesc.measurements m ",
  "join envirodat.VALID_MTHD_VAR vmv on m.vmv_code = vmv.vmv_code ",
  "join envirodat.variables v on VMV.variable_code = v.VARIABLE_CODE ",
  "join pesc.samples s on s.sample_no = m.sample_no ",
  "where s.project_no = 'PYLTM' ")

var_tbl <- dplyr::tbl(con, dbplyr::sql(vmv_query))

variables <- dplyr::collect(var_tbl) %>%
  #remove some variables
  dplyr::filter(!variable_group %in% organics_gr,
                !variable_name %in% c("WATER LEVEL ELEVATION"),
                !str_detect(variable_name, "UV ABSORBANCE")) %>%
  dplyr::mutate(method_code = as.numeric(method_code)) %>%
  dplyr::select(vmv = vmv_code, method_code, variable_code, variable_name, variable_group, unit_code) %>%
  dplyr::left_join(dplyr::select(ecwqData::vmv_xref, vmv, paramCODE, Analysis_Split), by="vmv") %>%
  dplyr::left_join(ecwqData::paramCODE_info, by = "paramCODE") %>%
  dplyr::arrange(vmv)

#check database against ecwqData::vmv_xref
#differences:
# - in variable_group names,
# - salinity units = "" in database and NA in ecwqData
# - vmv 108154 different parameter?

# variables2 <- ecwqData::vmv_xref %>%
#   dplyr::left_join(ecwqData::paramCODE_info, by = "paramCODE") %>%
#   dplyr::arrange(vmv)
#
# anti_join(variables %>% select(-variable_group), variables2 %>% select(-variable_group))

#write_rds(variables, here::here("data", "variables.rds"))
#----