disp('my')
[heart_scale_label, heart_scale_inst] = libsvmread('heart_scale');
model = svmtrain(heart_scale_label, heart_scale_inst, '-c 1 -g 0.07 -b 1');
[heart_scale_label, heart_scale_inst] = libsvmread('heart_scale');
[predict_label, accuracy, prob_estimates] = svmpredict(heart_scale_label, heart_scale_inst, model, '-b 1');