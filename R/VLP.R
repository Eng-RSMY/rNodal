#' @include utils.R settings.R  gas_correlations.R
#' @include friction.R oil_correlations.R interpolation.R
NULL


#  ########################
#' Globals
#'
PRES.ATM     = 14.7      # psia
TEMP.STD     = 60        # degrees Farenheit
TEMP.RANKINE = 460       # to convert to absolute temperature


# setProjectEnvironment()

saveToProjectEnv("PRES.ATM", 14.7)
saveToProjectEnv("TEMP.STD", 60)
saveToProjectEnv("TEMP.RANKINE", 460)





#' Build a deviation survey table given MD and TVD
#'
#' The table should be two columns of text
#'
#' @param well_as_string well deviation survey as two columns text
#' @export
set_deviation_survey <- function(well_as_string) {
    # read string text to dataframe
    well_table <- utils::read.table(header = TRUE, text = well_as_string)
    well_table
}





#' Set the high level model parameters for VLP calculations
#'
#' Prepare high level model inputs such as type of model, number of tubing segments,
#' tolerance for iterations, initial value of dp/dz putting them as a list.
#' Default VLP model is Hagendorn-Brown-Guo
#'
#' @param vlp.model     the name of the VLP model or correlation
#' @param segments      number of segments for the tubing string
#' @param tol           tolerance for error during interations
#' @param dp.dz.ini     initial gradient
#' @export
setVLPmodel <- function( vlp.model = "hagbr.guo",  # name of the VLP correlation
                         segments = 29,            # table rows = segments + 1
                         tol = 0.0001,             # tolerance in dp.dz calc
                         dp.dz.ini = 0.002         # initial value for dp.dz
                         ) {

    named.list(vlp.model,
               segments,
               tol,
               dp.dz.ini
               )
}



#' Set the most common well inputs
#'
#' Prepare all the well inputs to be entered into the VLP model by putting all
#' the inputs in a list.
#'
#' @param field.name field name. Usually comprises several wells
#' @param well.name  well name
#' @param depth.wh  depth at wellhead
#' @param depth.bh  depth at bottomhole of well                    feet
#' @param diam.in   well diameter                                  inches
#' @param GLR       gas liquid ratio
#' @param liq.rt    liquid rate
#' @param wcut      watercut
#' @param thp       tubing head pressure
#' @param tht       tubing head temperature
#' @param bht       bottomhole temperature
#' @param API       gravity of oil
#' @param gas.sg    specific gravity of gas
#' @param wat.sg    specific gravity of water
#' @param oil.visc  oil viscosity
#' @param ed        relative rougness
#' @param if.tens   interfacial tension between ...
#' @param salinity  water salinity
#' @param oil.cp    heat capacity of oil
#' @param gas.cp    heat capacity of gas
#' @param wat.cp    heat capacity of water
#' @param U         overall heat transfer coefficient
#' @param angle     angle of the well to the horizontal
#' @rdname setWellInput-VLP
#' @export
setWellInput <- function( field.name = "HAGBR.GUO",
                            well.name = "ExampleGuo",
                            depth.wh  = 0,               # depth at wellhead
                            depth.bh  = 9700,            # depth at bottomhole
                            diam.in   = 1.995,
                            GLR       = 75,
                            liq.rt    = 758,
                            wcut      = 0.10,
                            thp       = 200,       # tubing head pressure
                            tht       = 80,        # tubing head temperature
                            bht       = 180,       # bottomhole temperature
                            API       = 40,
                            gas.sg    = 0.7,
                            wat.sg    = 1.05,
                            oil.visc  = 5,
                            ed        = 0.0006,      # relative roughness
                            if.tens   = 30,
                            salinity  = 0,
                            U         = 8.0,         # heat transfer coefficient
                            oil.cp    = 0.53,        # heat capacity
                            gas.cp    = 0.5,
                            wat.cp    = 1.0,
                            angle     = pi/2
                        ) {

    # well input parameters
    out <- named.list(      field.name,
                            well.name,
                            depth.wh, tht,
                            depth.bh, bht,
                            diam.in, ed,
                            thp, liq.rt, wcut,
                            API, oil.visc,
                            gas.sg, GLR,
                            wat.sg,
                            salinity,
                            if.tens,
                            U,
                            oil.cp, gas.cp, wat.cp,
                            angle
    )
    return(out)
}


# load default values for well input
Gwell.input <- setWellInput()


#' Perform basic calculations based on the well inputs
#'
#' @param well.input well input data as a list
#' @export
getBasicCalcs <- function(well.input) {
    with(as.list(well.input), {

        # calculate temperature gradient
        temp.grad <- (bht - tht) / depth.bh

        # convert tubing diameter to ft
        diam <- diam.in /12
        diam.ft <- diam.in / 12

        # calculate area in ft^2
        area <- pi / 4 * diam^2

        # calculate specific gravity of oil from API
        oil.sg <- 141.5 / (131.5 + API)

        # oil and water fractions
        wat.fraction <- wcut
        oil.fraction <- 1 - wat.fraction
        WOR          <- wat.fraction / oil.fraction

        # calculate oil, gas and water rate at standard conditions
        # Options of names to use: oil.srt, gas.srt, wat.srt
        #                          OIL.RT, GAS.RT, WAT.RT
        #                          oil.Srt, gas.Srt, wat.Srt
        oil.rt <- liq.rt * oil.fraction
        gas.rt <- liq.rt * GLR
        wat.rt <- liq.rt * wat.fraction

        # GOR
        GOR = (oil.rt + wat.rt) / oil.rt * GLR

        # total mass per STB = mass oil + mass water + mass gas. C42.3
        mass.total <- oil.sg * 350 * (1 / (1+WOR)) +
            wat.sg * 350 * (WOR / (1+WOR)) +
            0.0764 * GLR * gas.sg

        # TODO: calculate fluid properties at P, T conditions

        # 4. calculate the mass flow rate w = m * q
        mass.rt  <-  mass.total * liq.rt
        mass.rate <- mass.rt

        # heat capacity
        cp.avg <- (oil.cp + gas.cp + wat.cp) /3

        # calculated
        out.calc <- named.list( temp.grad,
                                diam, area, diam.ft,         # added diam.ft
                                oil.sg,
                                oil.fraction, wat.fraction, WOR,
                                oil.rt, gas.rt, wat.rt,
                                mass.total,
                                GOR,
                                mass.rt, mass.rate,
                                cp.avg
        )
        return(out.calc)
    })
}


#' Get the well input together with the basic calculations
#'
#' @param well.input the well input
#' @export
get_well_parameters <- function(well.input) {
    # perform basic calculations on the well input
    basic.calcs <-  getBasicCalcs(well.input)
    well.parameters <- c(well.input, basic.calcs)
    well.parameters
}



#' Run the VLP calculations based on well inputs and model parameters
#'
#' Calls VLPcontrol() to run the subsusrface calculations
#'
#' @param well.input        well input data as a list
#' @param hdf5 do we want to write to an HDF5 file
#' @param model.parameters  well model parameters as a list
#' @export
runVLP <- function(well.input, model.parameters, hdf5 = FALSE) {

    # perform basic calculations on the well input
    basic.calcs <-  getBasicCalcs(well.input)
    well.parameters <- c(well.input, basic.calcs) # join input and calc output

    # pass the well parameters and model parameters
    vlp.output <- VLPcontrol(well.parameters, model.parameters, hdf5 = hdf5)

    vlp.model <- toupper(model.parameters$vlp.model) # model name in uppercase

    if (hdf5) {
        # save input and output to HDF5 file
        writeHdf5(well.input,  "well.input")
        writeHdf5(basic.calcs, "core.calcs")
        writeHdf5(vlp.output,  "vlp.output")
        writeHdf5(vlp.model,   "vlp.model")
    }


    return(tibble::as_tibble(vlp.output))                 # return dataframe
}




#' VLP calculation algorithm
#'
#' VLP control marching algorithm to calculate bottomhole pressure given the
#' wellhead pressure and temperature. Fluid properties are calculated at each
#' of the segment depths.
#'
#' @param well.parameters    well input and core calculations at surface
#' @param model.parameters   model characteristics. Hagedorn-Brown, Duns-Ros,
#'                           Fancher-Brown, etc. Also tolerances and boundaries
#' @param hdf5 do we want to write to an HDF5 file
#' @param verbose prevent printing messages. Default is FALSE
#'
#' @export
VLPcontrol <- function(well.parameters, model.parameters,
                       hdf5 = FALSE,
                       verbose = FALSE) {
    # called by runVLP()
    with(as.list(c(well.parameters, model.parameters)),
    {
        # get datetime slot for saving /field/well/dataset to HDF5
        if (hdf5) .saveSlot(field.name, well.name)
        if (verbose) cat("VLP control for well model:", vlp.model, "\n")

        # load the VLP function that is needed
        vlp.function = loadVLP(vlp.model)
        # Calculate the well segments and depths
        # Depth counts have to be greater than segments to allocate the zero or
        # initial depth value.
        # Consider that in R for length.out parameter.
        # In R index starts at 1 not 0
        depths <- seq.int(from = depth.wh, to = depth.bh, length.out = segments+1)
        n      <- length(depths)   # which is the same as # rows in the dataframe
        depth.top <- depths[1]                # take the the first depth

        dp.dz     <- dp.dz.ini                # 1st approximation of the gradient
        p0        <- thp                      # the initial pressure
        t0        <- tht                      # initial temperature
        dt.dz     <- temp.grad                # temperature gradient at inlet

        # initialize vectors of list type to store row calculations
        segment_row_vector <- vector("list", n)
        iter_row_vector    <- vector("list")

        cum_iter <- 1                      # counter for all iterations
        for (i in seq_len(n)) {            # n is the number of depths = # rows
            # make the previous depth the top but do this only for the 1st row
            # otherwise, use the previous depth
            if (i == 1) depth.prev = depth.top else depth.prev = depths[i-1]
            dL  <- depths[i] - depth.prev       # calculate dL
            # prepare p1, t1 for iteration
            p1  <- p0 + dp.dz * dL              # calculate outlet pressure
            t1  <- t0 + dt.dz * dL              # calculate outlet temperature
            eps <-  1                           # initial value for epsilon
            iter_dpdz <- 1                      # AE: absolute error
            # here we start iterating for the pressure gradient
            # until it is within the specified tolerance
            while (eps > tol) {           # loop until AE greater than tolerance
                p.avg <- (p0 + p1) / 2    # try with an initial pressure
                t.avg <- (t0 + t1) / 2
                # calculate pressure losses using the selected VLP correlation
                # passing the current pressure, temperature and other parameters
                corr  <- vlp.function(pres = p.avg, temp = t.avg, well.parameters)
                dp.dz <- corr$dp.dz       # extract dp/dz or pressure gradient
                z     <- corr$z
                # calculate new pressure
                p.calc <- p0 - (-dp.dz) * dL # negative, we are going down
                eps    <- abs( (p1 - p.calc) / p.calc )  # absolute error
                # build iteration row-vector
                iter_row_vector[[cum_iter]] <- list(
                    segment = i,
                    iter_dpdz = as.integer(iter_dpdz),
                    epsilon = eps,
                    p0 = p0, p1 = p1, p.calc = p.calc,
                    p.avg = p.avg, delta.P = abs(p1-p.calc),
                    depth = depths[i], dL = dL,
                    dp.dz = dp.dz, temp = t1
                    )
                if (eps >= tol) p1 = p.calc   # if error too big, iterate again
                iter_dpdz <- iter_dpdz + 1    # with a a new p1
                cum_iter <- cum_iter + 1      # number of total iterations
            } # end of while
            # at the end of the while-loop we obtain the average pressure
            # build a row-vector out of: depth, dL, temperature, pressure,
            # segment, correlation results
            segment_row_vector[[i]] <- c(
                i = i,             # row number
                depth = depths[i], # depth
                dL = dL,           # length of pipe increment
                temp = t1,         # current temperature
                pres = p1,         # current pressure at depth
                p_avg = p.avg,
                t_avg = t.avg,
                segment = i-1,     # segment number
                corr               # correlation results
                )
            p0 = p.calc   # assign p1 to the inlet pressure of new segment, p0
            t0 = t1       # do the same with the temperature
    } # end-for
        # convert row-list to dataframe
        iter.tbl <- data.table::rbindlist(iter_row_vector)
        # print(iter.tbl)                     # show the dataframe
        # TODO: maybe we should make writeHDF5() an option
        if (hdf5) writeHdf5(iter.tbl, "iterations")     # write table to HDF5
    # convert row-vector to a dataframe
    segment_tbl <- data.table::rbindlist(segment_row_vector) # add row to table
    return(segment_tbl)                           # final results
    }) # end with
}


runVLPdefaults <- function() {
    # FIX: error inside loop with `tol`
    well.inputs      <- setWellInput()
    model.parameters <- setVLPmodel()

    runVLP(well.input = well.inputs, model.parameters = model.parameters)
    #return(well.inputs)
    #return(c(well.inputs, model.parameters))
}


#' Load only the source necessary for model or correlation
#' Note: it doesn't unload the functions sourced yet
#' @param model   the model name       string
#'
loadVLP <- function(model) {
    modelU <- toupper(model)
    # if (grepl("HAGBR", modelU))    source("HAGBR.R")
    # if (grepl("DUNSROS", modelU))  source("DUNSROS.R")
    # if (grepl("FANBR", modelU))    source("FANBR.R")

    if (model == "hagbr.guo")      return(hagbr.guo)
    if (model == "hagbr.dummy")    return(hagbr.dummy)
    if (model == "hagbr.mod")      return(hagbr.mod)
    if (model == "dunsros.0")      return(dunsros.0)
    if (model == "fanbr.fanbr")    return(fanbr.fanbr)
}




#' Write dataset to HDF5 file
#'
#' @param dataTable data that is going to be written
#' @param dataset.name the name of the dataset
#' @importFrom rhdf5 h5write H5close
#' @keywords internal
writeHdf5 <- function(dataTable, dataset.name) {
    wellFile <- readFromProjectEnv("data.file.hdf5")
    slot     <- readFromProjectEnv("slot")
    data.name <- paste(slot, dataset.name, sep = "/")
    # print(dataTable); print(wellFile); print(data.name)
    rhdf5::h5write(dataTable, wellFile, data.name)                            # hdf5 error
    H5close()
}

#' Save a slot in the HDF5 file
#' @param field.name field name to compose the slot
#' @param well.name well name to compose the slot
#' @noRd
#' @keywords internal
.saveSlot <- function(field.name, well.name) {
    hFile <- readFromProjectEnv("data.file.hdf5")
    # get the well slot in HDF5
    slot <- get.well.slot(hFile, field.name, well.name)                  # io error 3
    if (is.null(slot)) stop("Slot not available. Check Field name or Well name.")
    saveToProjectEnv("slot", slot)
    return(project.env[["slot"]])
}







