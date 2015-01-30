% predict a single particle
function particle = PredictParticle( varianceX,...
                                    varianceY,...
                                    varianceScaleX,...
                                    varianceScaleY,...
                                    particle )
                                
    varianceX        = max( 1e-10, varianceX );
    varianceY        = max( 1e-10, varianceY );
    varianceScaleX   = max( 1e-10, varianceScaleX );
    varianceScaleY   = max( 1e-10, varianceScaleY );

    mu    = [ 0 0 0 0];
    sigma = [   varianceX 0 0 0;
                0 varianceY 0 0;
                0 0 varianceScaleX 0;
                0 0 0 varianceScaleY ];

    %cholesky factorization for getting a proper covariance matrix
    R = chol(sigma);
    
    Np =  size(particle, 1);

    z = repmat(mu,Np,1) + randn( Np, 4 ) * R;
    
    particle =  particle + z;
end