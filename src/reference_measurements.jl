function generate_densities(data_path::String, unc_path::String; model_name::String="autochem-w-ions", replacement_dict=Dict("CH3OH" => "MeOH"))
    # if file already exists, delete it
    outpath1 = "./models/$(model_name)/mechanism/number_densities.csv"
    outpath2 = "./models/$(model_name)/mechanism/state_parameters.csv"  # i.e. M, O2, N2, H2O + Temp, Pressure
    outpath3 = "./models/$(model_name)/mechanism/number_densities_ϵ.csv"
    outpath4 = "./models/$(model_name)/mechanism/state_parameters_ϵ.csv"

    if isfile(outpath1) || isfile(outpath2) || isfile(outpath3) || isfile(outpath4)
        rm(outpath1)
        rm(outpath2)
        rm(outpath3)
        rm(outpath4)
    end

    # make sure output dir exists
    if !isdir("./models/$(model_name)/mechanism")
        mkdir("./models/$(model_name)/mechanism")
    end


    # load in data
    df_number_densities = CSV.read(data_path, DataFrame)
    df_number_densities_ϵ = CSV.read(unc_path, DataFrame)

    # add column to indicate active pure or not
    is_ap_on = [ t ≥ 0.0 for t ∈ df_number_densities.t]
    df_number_densities.w_ap = is_ap_on
    df_number_densities_ϵ.w_ap = is_ap_on


    # separate into state variables and measurements
    state_params = ["M", "O2", "N2", "H2O"]

    df_state = df_number_densities[:, vcat(state_params, "t", "temperature", "pressure", "w_ap")]
    df_state_ϵ = df_number_densities_ϵ[:, vcat(state_params, "t", "temperature", "pressure", "w_ap")]

    df_nd = df_number_densities[:, Not(vcat(state_params, "temperature", "pressure"))]
    df_nd_ϵ = df_number_densities_ϵ[:, Not(vcat(state_params, "temperature", "pressure"))]


    # loop through replacement dict and rename columns
    for name ∈ names(df_number_densities)
        if name ∈ keys(replacement_dict)
            println("renaming $(name) to $(replacement_dict[name])")
            rename!(df_nd, name => replacement_dict[name])
            rename!(df_nd_ϵ, name => replacement_dict[name])
        end
    end


    CSV.write(outpath1, df_nd)
    CSV.write(outpath2, df_state)
    CSV.write(outpath3, df_nd_ϵ)
    CSV.write(outpath4, df_state_ϵ)
end
