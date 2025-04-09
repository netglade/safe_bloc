## 1.4.0
- Dependencies updated

## 1.3.0
- Dependencies updated
- Fix dcm warning

## 1.2.1
- Fix nullability of trackingId in error handler

## 1.2.0
- Use `trackable` package
- UnexpectedError is now implementing GeneralTrackableError.
- **Breaking**: Remove TrackingIdService. Use trackable package instead.
- `trackable` package is re-exported with safe_bloc

## 1.1.0
- `errorMapper` parameter added for mapping individual exceptions to bloc/cubit states
- typdefs for callbacks added

## 1.0.2
- Fix pub icons again 🤡.

## 1.0.1
- Fix pub icons.

## 1.0.0
- Add description of `safeCallSync` to README.

## 1.0.0-rc.3
- Add synchronous`safeCallSync` method to support cubits.

## 1.0.0-rc.2
- `UnexpectedErrorAPI` renamed to -> `UnexpectedErrorBase`
- bloc presentation test added for testing blocs and cubits with presentation
- `SafeBlocWithPresentation` and `SafeCubitWithPresentation` added

## 1.0.0-rc.1
- Initialize package.