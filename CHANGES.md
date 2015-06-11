# 0.2.4

- Added `#all_resources` to transparently download and flatten lists in `ChangeListIndex` and `ResourceListIndex`
- Added `#all_zip_packages` to transparently download and flatten dumps in `ChangeDumpIndex` and `ResourceDumpIndex`
- Fix issue where documentation on mixin modules was mistakenly applied to the `Resync` module

# 0.2.3

- Update to depend on [resync](https://github.com/dmolesUC3/resync) 0.2.2

# 0.2.2

- Replaced `Bistream#stream` with `Bitstream#get_input_stream`, which (unlike the former) returns a new stream with each invocation.
- Update to depend on [resync](https://github.com/dmolesUC3/resync) 0.2.1

# 0.2.1

- Update to depend on [resync](https://github.com/dmolesUC3/resync) 0.1.3
- Add more tests for client delegation

# 0.2.0

- Use named mixins instead of instance monkey-patching for easier documentation and navigation.
- Update to depend on [resync](https://github.com/dmolesUC3/resync) 0.1.2

# 0.1.2

- Change the `:zip_packages` extension method on `ResourceDump` and `ChangeDump` to return a lazy enumerable instead of preemptively downloading all packages. 

# 0.1.1

- Update to depend on [resync](https://github.com/dmolesUC3/resync) 0.1.1

# 0.1.0

- Initial release
