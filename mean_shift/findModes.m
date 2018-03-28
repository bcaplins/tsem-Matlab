function [modes, mode_pr, labels] = findModes(points, n_seeds, dTol)

    [n_pts, n_dims]   = size(points);
    points          = points(:,1:n_dims);
    
    tTol            = 0.01;  % mean shift translation tolerance
    bandwidth       = .1;
   
    seed_modes      = points(randi(n_pts, n_seeds,1),1:n_dims); % seeds
    stationary_pts  = [];
    modes           = [];
    labels          = zeros(1,n_pts);
    i = 1;
    j = 1;

    % ---------------------------------------------------------------------
    while (i <= n_seeds)
        mean_shift  = ones(1,n_dims) ;
        while (norm(mean_shift,2) > tTol)
            mean_shift       = compute_meanshift( seed_modes(i,:), ...
                                                  points,          ...
                                                  bandwidth);
                                        
            seed_modes(i,:)  = seed_modes(i,:) + mean_shift;
        end
        
        is_stationary = perturb_mode( seed_modes(i,:),...
                                     points,         ...
                                     bandwidth) ;
        if is_stationary
            stationary_pts(j,:) = seed_modes(i,:);
            j = j+1;
        else
            disp('--> Mode not stationary')
        end
        
        i = i+1;
    end
%     modes = stationary_pts;
    modes             = merge_clusters( stationary_pts, ...
                                         dTol);
    [mode_pr, labels] = compute_probabilities( points, ...
                                               modes,  ...
                                               labels);
% -------------------------------------------------------------------------
function [mode_pr, labels] = compute_probabilities( points, ...
                                                    modes,  ...
                                                    labels)
    n_modes      = size(modes, 1);
    n_pts        = size(points,1);
    mode_pr      = zeros(n_modes,1);
    
    for i = 1:1:n_pts
        offset   = repmat(points(i,:),n_modes,1) - modes;
        dist     = sum(offset.^2,2);
        
        [~,labels(i)] = min(dist);
    end
    
    for i =1:n_modes
        pts_class = labels == i;
        mode_pr(i) = sum(pts_class)/n_pts;
    end
% -------------------------------------------------------------------------
function [success]    = perturb_mode(  mode,  ...
                                       points,...
                                       bandwidth)
                                
    [~,len]        = size(mode);
    perturbation   = randn(1,len)/100;
    offsetTol      = 0.1;
    perturbed_mode = mode + perturbation;
    
    for i = 1:100
        mean_shift = compute_meanshift( perturbed_mode,   ...
                                        points, ...
                                        bandwidth);
        perturbed_mode = perturbed_mode + mean_shift;
        offset = norm(mean_shift,2);
        if ( offset < offsetTol)
            break
        end
    end
    
    if ( offset < offsetTol)
        success = true;
    else
        success = false;
    end
% -------------------------------------------------------------------------    
% - merge the modes generated from seeds. Two modes are merged if the dist
% - between them < dTol
function [modes]      = merge_clusters(  stationary_pts, ...
                                         dTol)
    nModes = size(stationary_pts,1);
    mode_flags = true(nModes,1);                % visit all modes - initialization
    j = 1;
    for i=1:nModes
        if (mode_flags(i))
            fprintf('Visiting cluster %d \n',i)
            offset = stationary_pts - repmat( stationary_pts(i,:), ...
                                              nModes,1);
            dist_sq = sum(offset.*offset,2);
            merge = dist_sq < dTol*dTol;        % which modes are close to me
            for k = 1:nModes
                if (merge(k))
                    mode_flags(k) = false; % dont visit modes that are close 
                end
            end
            
            modes(j,:) = stationary_pts(i,:);
            j = j+1;
            for k = i:nModes
                if(merge(k))
                    fprintf('Merged cluster %d with %d\n',k,i)
                end
            end
        else
            
        end
    end
% -------------------------------------------------------------------------
% - finds all the nieghboring pts of query pts that lie within the bandwidth
function [mean_shift] = compute_meanshift(  query_pt, ...
                                            pts,      ...
                                            bandwidth)
    [n_pts,n_dims] = size(pts);
    weights      = kernelized_weights(   query_pt, ...
                                    pts,      ...
                                    bandwidth,...
                                    'radial');
    weighted_pts = zeros(n_pts, n_dims);
    for i=1:n_dims
        weighted_pts(:,i) = pts(:,i).*weights; 
    end
    mean_shift   = (sum(weighted_pts,1)/sum(weights,1))-query_pt;
% -------------------------------------------------------------------------
% - compute the weights of each point
function [k_weights]  = kernelized_weights(  query_pt, ...
                                             pts,      ...
                                             bandwidth,...
                                             kernel_type)
    [n_pts,~] = size(pts);
    if strcmp(kernel_type, 'radial')
        norm_const       = 1/(bandwidth*sqrt(2*pi));
        inv_bandwidth_sq = 1/(bandwidth*bandwidth);

        offset           = pts - repmat(query_pt,n_pts,1);
        euclidean_dist   = sum(offset.*offset,2) .* inv_bandwidth_sq;

        k_weights        = norm_const* ...
                           exp(-0.5 * inv_bandwidth_sq * euclidean_dist);
    else
        error ('Unknown kernel')
    end
% -------------------------------------------------------------------------
