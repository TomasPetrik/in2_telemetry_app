import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/mapper/measurement_type_mapper.auto_mappr.dart';

@injectable
@AutoMappr([
  MapType<MeasurementTypeContract, MeasurementType>(
    reverse: true,
  ),
])
class MeasurementTypeMapper extends $MeasurementTypeMapper {
  const MeasurementTypeMapper();
}
