function classifier = ensemble_update(x, y, Nrounds, ensemble, K)
% Adopted from Prof.Antonio's Torralba's implementation of Gentle Boost
[Nfeatures, Nsamples] = size(x); % Nsamples = Number of thresholds that we will consider
Fx = zeros(1, Nsamples); 

%% 6. Initialize w to be a uniform distribution
w  = ones(1, Nsamples);

%% 7. Removing the K oldest weak classifiers ... here 3 classifiers with maximum error have been removed
for iter = K+1:Nrounds
    classifier{iter} = ensemble{iter-K};
    k = classifier{iter}.featureNdx;    a = classifier{iter}.a;    b = classifier{iter}.b;    th = classifier{iter}.th;
    fm = (a * (x(k,:)>th) + b); % evaluate weak classifier
    Fx = Fx + fm; % update strong classifier
    % Reweight training samples
    w = w .* exp(-y.*fm);
    
% % % % %     %% Additional Part for Checking Efficiency ...
    fm_modified = fm;
    fm_modified(fm_modified == 0) = .1;
    sign_checker = y.*(fm_modified + eps.^3);
    current_op = sign(fm_modified);
        
    sign_checker_pos = current_op(y==1) .* y(y==1);
    sign_checker_neg = current_op(y==-1) .* y(y==-1);
    
    classifier{iter}.err = sum(sign_checker<0);
    classifier{iter}.pos_err = sum(sign_checker_pos<0);
    classifier{iter}.neg_err = sum(sign_checker_neg<0);
end

%% 8.
for m = 1:K
    %% Weak regression stump: It is defined by four parameters (a,b,k,th) f_m = a * (x_k > th) + b
    [k, th, a , b, current_error] = selectBestRegressionStump(x, y, w);
    % Round m update of the weak learners
    classifier{m}.featureNdx = k;    classifier{m}.th = th;             classifier{m}.a  = a;
    classifier{m}.b  = b;            classifier{m}.err = current_error; classifier{m}.dist = w./sum(w);
    % Updating and computing classifier output on training samples
    fm = (a * (x(k,:)>th) + b); % evaluate weak classifier
    Fx = Fx + fm; % update strong classifier
    % Reweight training samples
    w = w .* exp(-y.*fm);
    
    %% Additional Part for Checking Efficiency ...
    fm_modified = fm;
    fm_modified(fm_modified == 0) = .1;
    sign_checker = y.*(fm_modified + eps.^3);
    current_op = sign(fm_modified);
        
    sign_checker_pos = current_op(y==1) .* y(y==1);
    sign_checker_neg = current_op(y==-1) .* y(y==-1);
    
    classifier{m}.err = sum(sign_checker<0);
    classifier{m}.pos_err = sum(sign_checker_pos<0);
    classifier{m}.neg_err = sum(sign_checker_neg<0);
    
      
end