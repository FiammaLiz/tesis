%%SELECCIONA TRIALS 

samples_feos= {1:t0s(5)*sample_rate-1; t0s(6)*sample_rate:t0s(8)*sample_rate-1; t0s(17)*sample_rate:t0s(18)*sample_rate-1};
trials_sanos= {5, 8:16, 18:30};


for t=1:length(samples_feos)
channel_neural_data(samples_feos{t},:)=[];
end


trial_s= cell2mat(trials_sanos);
num_stim=num_stim(trial_s);
name_stim=name_stim(trial_s);
t0s=t0s(trial_s);
