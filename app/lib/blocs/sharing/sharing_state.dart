import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/nullable.dart';

class SharingState extends Equatable {
  final String? myID;
  final String? partnerID;
  final List<String> partnerNames;
  final String? error;

  const SharingState(this.myID, this.partnerID, this.partnerNames, this.error)
      : super();

  SharingState.initial()
      : myID = null,
        partnerID = null,
        partnerNames = List.empty(),
        error = null;

  SharingState copyWith(
          {Nullable<String?>? myID,
          Nullable<String?>? partnerID,
          List<String>? partnerNames,
          Nullable<String?>? error}) =>
      SharingState(
          myID == null ? this.myID : myID.value,
          partnerID == null ? this.partnerID : partnerID.value,
          partnerNames ?? this.partnerNames,
          error == null ? this.error : error.value);

  @override
  List<Object?> get props => [myID, partnerID, partnerNames, error];
}
