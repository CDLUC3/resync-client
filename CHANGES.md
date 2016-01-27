## 0.4.2

- Make gemspec smart enough to handle SSH checkouts
- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.4.2

## 0.4.1

- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.4.1

## 0.4.0

- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.4.0

## 0.3.5

- Fix issue where `Dir.glob` could cause files to be required in an unpredictable order (h/t [nabeta](https://github.com/CDLUC3/resync/pull/1))
- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.3.4

## 0.3.4

- Move GitHub project to [CDLUC3](https://github.com/CDLUC3/)
- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.3.2

## 0.3.3

- Make `#all_zip_packages` on `ChangeDump` and `ResourceDump` return `Enumerator::Lazy` to improve interoperation with the corresponding methods on `ResourceDumpIndex/ChangeDumpIndex`

## 0.3.2

- Added utility methods to `CapabilityList` to simplify downloading and parsing ResourceSync documents by capability
- Make `ChangeList#all_changes`, and `#all_resources` on both `ResourceList` and `ChangeList`, return `Enumerator::Lazy` to improve interoperation with the corresponding methods on `ResourceIndex/ChangeIndex`

## 0.3.1

- Make `#get` and `#get_and_parse` in `Downloadable` (i.e., `Resource` and `Link`) cache the downloaded content

## 0.3.0

- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.3.0
- Replace `ZipPackages` class with simple enumerable

## 0.2.6

- Added `#all_resources` (as alias for `#resources`) to `ChangeList`/`ResourceList` for transparent interoperability with `ChangeListIndex`/`ResourceListIndex`
- Added `#all_changes` (as alias for `#changes`) to `ChangeList`/`ChangeDump` for transparent interoperability with `ChangeListIndex`/`ChangeDumpIndex`
<!-- TODO: figure out what ChangeDump#all_changes should really do -->
- Added `#all_zip_packages` (as alias for `#zip_packages`) to `ChangeDump`/`ResourceDump` for transparent interoperability with `ChangeDumpIndex`/`ResourceDumpIndex`

## 0.2.5

- Added `#all_changes` to transparently download and flatten changes in `ChangeListIndex` and `ChangeDumpIndex` documents, with filtering by time and type

## 0.2.4

- Added `#all_resources` to transparently download and flatten lists in `ChangeListIndex` and `ResourceListIndex`
- Added `#all_zip_packages` to transparently download and flatten dumps in `ChangeDumpIndex` and `ResourceDumpIndex`
- Fix issue where documentation on mixin modules was mistakenly applied to the `Resync` module

## 0.2.3

- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.2.2

## 0.2.2

- Replaced `Bistream#stream` with `Bitstream#get_input_stream`, which (unlike the former) returns a new stream with each invocation.
- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.2.1

## 0.2.1

- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.1.3
- Add more tests for client delegation

## 0.2.0

- Use named mixins instead of instance monkey-patching for easier documentation and navigation.
- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.1.2

## 0.1.2

- Change the `:zip_packages` extension method on `ResourceDump` and `ChangeDump` to return a lazy enumerable instead of preemptively downloading all packages. 

## 0.1.1

- Update to depend on [resync](https://github.com/CDLUC3/resync) 0.1.1

## 0.1.0

- Initial release
