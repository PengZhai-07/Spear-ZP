#####################################
# DAMAGE EVOLUTION IN TIME
#####################################

function damage_indx!(ThickX, ThickY, dxe, dye, NGLL, NelX, NelY, iglob)
    # return the global index of fault zone elements

    ww::Matrix{Float64} = zeros(NGLL, NGLL)
    Ke2::Array{Float64,4} = zeros(NGLL,NGLL,NGLL,NGLL)
    Ke3::Array{Float64,4} = zeros(NGLL,NGLL,NGLL,NGLL)
    Ke_d::Array{Float64,3} = zeros(NGLL*NGLL,NGLL*NGLL, NelX*NelY)
    Ke_und::Array{Float64,3} = ones(NGLL*NGLL,NGLL*NGLL, NelX*NelY)

    @inbounds @fastmath for ey = 1:NelY
        @inbounds @fastmath for ex = 1:NelX
            eo = (ey-1)*NelX + ex
            ig = iglob[:,:,eo]

            # Properties of heterogeneous medium
            for i in 1:NGLL, j in 1:NGLL
                for k in 1:NGLL, l in 1:NGLL
                    # damage zone
                    if ex*dxe >= ThickX && (dye <= ey*dye <= ThickY)
                        Ke2[i,j,k,l] = 1000.0   # with no specific meanings, only to find id of GLL nodes in fault damage zone!!
                        #  Ke3[i,j,k,l] = 0.0
                    # host rock
                    else
                        Ke2[i,j,k,l] = -1000
                    end
                end
            end
            Ke_d[:,:,eo] = reshape(Ke2,NGLL*NGLL,NGLL*NGLL)
            #  Ke_und[:,:,eo] = reshape(Ke3,NGLL*NGLL,NGLL*NGLL)
        end
    end

    Kdam = FEsparse(NelX*NelY, Ke_d, iglob)
    #  Kdam[Kdam .> 1.0] .= 1.0

    #  Kudam = FEsparse(NelX*NelY, Ke_und, iglob)
    #  Kudam[Kudam .> 1.0] .= 1.0

    return findall(Kdam .> 0)

end
