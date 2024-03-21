import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/time_settings/when_code_contract.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';
import 'package:scalesoft_app/mapper/when_code_mapper.auto_mappr.dart';

@injectable
@AutoMappr([
  MapType<WhenCodeContract, WhenCode>(
    reverse: true,
  ),
])
class WhenCodeMapper extends $WhenCodeMapper {
  const WhenCodeMapper();
}
