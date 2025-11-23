import importlib.util,sys
spec=importlib.util.spec_from_file_location('api_main','/Users/sky/Desktop/ML Summative/linear_regression_model/API/main.py')
mod=importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
print('Imported OK')
print('MODEL:', getattr(mod,'MODEL',None))
print('MODEL_COEFFICIENTS len:', None if getattr(mod,'MODEL_COEFFICIENTS',None) is None else len(mod.MODEL_COEFFICIENTS))
print('MODEL_INTERCEPT:', getattr(mod,'MODEL_INTERCEPT',None))
if getattr(mod,'MODEL_COEFFICIENTS',None) is not None:
    sample=[20,85,75,2,0,1,0,1,1,0,1,0,1,0,1,1,0,1,0,1,0]
    print('sample prediction ->', mod.make_prediction(sample))
