%Take two nodes, moving source and moving destination
%Broadcast time is the expected time that the moving destination will
%take to reach the moving source from its initial position

time_slots = 10^5;
num_runs = 10^4;
torus_lim = 10;
num_nodes = 5;
stickiness = 0.1 : 0.1 : 0.9;
rw_vars = [1 : 1 : 10];
bcast_time = zeros(size(stickiness,2),1);
for i = 1 : size(stickiness,2)
    
    for run = 1 : num_runs
        src_node = zeros(1,num_nodes);
        src_node(1) = 1;
                
        stick = stickiness(i)*10;
        zero_arr = rw_vars(1 : stick);
        n = size(rw_vars,2) - stick;
        if (rem(n,2) == 0)
            pone_arr = rw_vars(stick + 1 : stick + (n/2));
            mone_arr = rw_vars(stick + (n/2) + 1 : 10);
        else
            pone_arr = rw_vars(stick + 1 : stick + ((n+1)/2));
            mone_arr = rw_vars(stick + ((n+1)/2) + 1 : 10);
        end
        
        node_pos = randi([0 torus_lim], 1, num_nodes);
        rw_vals = randi([1 10],time_slots,num_nodes);
        
        for tmp = 1 : size(zero_arr,2)
            rw_vals(rw_vals == zero_arr(tmp)) = 0;
        end
        for tmp = 1 : size(pone_arr,2)
            rw_vals(rw_vals == pone_arr(tmp)) = 1;
        end
        for tmp = 1 : size(mone_arr,2)
            rw_vals(rw_vals == mone_arr(tmp)) = -1;
        end
        
        allnodes = 1: 1: num_nodes;
        rem_nodes = setdiff(allnodes,src_node);
        slot = 1; src_indx = 1;
        while (slot <= time_slots)           
           
           bool_tmp = (node_pos(rem_nodes) == any(node_pos(src_node(1:src_indx))));
           nz_ind = find(bool_tmp ~= 0);
           if (size(nz_ind,2) > 0)
               for tmp = 1 : size(nz_ind,2)
                   src_indx = src_indx + 1;
                   src_node(src_indx) = rem_nodes(nz_ind(tmp));
               end
               rem_nodes = setdiff(allnodes,src_node);
           end
           
           if (size(rem_nodes,2) == 0)
              break;
           end  
           
           node_pos = node_pos + rw_vals(slot,:);
           node_pos(node_pos == (torus_lim+1)) = -torus_lim;
           node_pos(node_pos == -torus_lim-1) = torus_lim;
           
           slot = slot + 1;
        end
        bcast_time(i) = bcast_time(i) + slot;
    end
    fprintf('Broadcast time for %d nodes is %d\n',num_nodes,bcast_time(i));
end
bcast_time = bcast_time./num_runs;

figure;
plot(stickiness, bcast_time, 'b--o');
xlabel('Stickiness factor');
ylabel('Broadcast time');
title('Average broadcast time for multi node setup');

