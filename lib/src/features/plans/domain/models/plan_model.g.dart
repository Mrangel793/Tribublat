// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanModelImpl _$$PlanModelImplFromJson(Map<String, dynamic> json) =>
    _$PlanModelImpl(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      imagenBase64: json['imagenBase64'] as String? ?? '',
      categoria: $enumDecode(_$PlanCategoryEnumMap, json['categoria']),
      estado:
          $enumDecodeNullable(_$PlanStatusEnumMap, json['estado']) ??
          PlanStatus.activo,
      organizadorId: json['organizadorId'] as String,
      organizadorNombre: json['organizadorNombre'] as String,
      organizadorFoto: json['organizadorFoto'] as String? ?? '',
      organizadorReputacion:
          (json['organizadorReputacion'] as num?)?.toDouble() ?? 0.0,
      fechaHora: DateTime.parse(json['fechaHora'] as String),
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      duracionMinutos: (json['duracionMinutos'] as num?)?.toInt() ?? 120,
      ciudad: json['ciudad'] as String,
      ubicacionNombre: json['ubicacionNombre'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      capacidadMaxima: (json['capacidadMaxima'] as num).toInt(),
      capacidadActual: (json['capacidadActual'] as num?)?.toInt() ?? 0,
      participantesIds:
          (json['participantesIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      listaEsperaIds:
          (json['listaEsperaIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nivelEnergia:
          $enumDecodeNullable(_$EnergyLevelEnumMap, json['nivelEnergia']) ??
          EnergyLevel.media,
      tipoPrecio:
          $enumDecodeNullable(_$PlanPriceTypeEnumMap, json['tipoPrecio']) ??
          PlanPriceType.gratis,
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda'] as String? ?? 'COP',
      interesesRelacionados:
          (json['interesesRelacionados'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      esPublico: json['esPublico'] as bool? ?? true,
      requiereAprobacion: json['requiereAprobacion'] as bool? ?? false,
      vistas: (json['vistas'] as num?)?.toInt() ?? 0,
      puntuacionPromedio:
          (json['puntuacionPromedio'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$PlanModelImplToJson(_$PlanModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'descripcion': instance.descripcion,
      'imagenBase64': instance.imagenBase64,
      'categoria': _$PlanCategoryEnumMap[instance.categoria]!,
      'estado': _$PlanStatusEnumMap[instance.estado]!,
      'organizadorId': instance.organizadorId,
      'organizadorNombre': instance.organizadorNombre,
      'organizadorFoto': instance.organizadorFoto,
      'organizadorReputacion': instance.organizadorReputacion,
      'fechaHora': instance.fechaHora.toIso8601String(),
      'fechaCreacion': instance.fechaCreacion.toIso8601String(),
      'duracionMinutos': instance.duracionMinutos,
      'ciudad': instance.ciudad,
      'ubicacionNombre': instance.ubicacionNombre,
      'latitud': instance.latitud,
      'longitud': instance.longitud,
      'capacidadMaxima': instance.capacidadMaxima,
      'capacidadActual': instance.capacidadActual,
      'participantesIds': instance.participantesIds,
      'listaEsperaIds': instance.listaEsperaIds,
      'nivelEnergia': _$EnergyLevelEnumMap[instance.nivelEnergia]!,
      'tipoPrecio': _$PlanPriceTypeEnumMap[instance.tipoPrecio]!,
      'precio': instance.precio,
      'moneda': instance.moneda,
      'interesesRelacionados': instance.interesesRelacionados,
      'esPublico': instance.esPublico,
      'requiereAprobacion': instance.requiereAprobacion,
      'vistas': instance.vistas,
      'puntuacionPromedio': instance.puntuacionPromedio,
    };

const _$PlanCategoryEnumMap = {
  PlanCategory.gastronomia: 'gastronomia',
  PlanCategory.deportes: 'deportes',
  PlanCategory.cultura: 'cultura',
  PlanCategory.vidaNocturna: 'vidaNocturna',
  PlanCategory.naturaleza: 'naturaleza',
  PlanCategory.tecnologia: 'tecnologia',
  PlanCategory.arte: 'arte',
  PlanCategory.musica: 'musica',
  PlanCategory.cine: 'cine',
  PlanCategory.viajes: 'viajes',
  PlanCategory.otros: 'otros',
};

const _$PlanStatusEnumMap = {
  PlanStatus.activo: 'activo',
  PlanStatus.lleno: 'lleno',
  PlanStatus.enProgreso: 'enProgreso',
  PlanStatus.finalizado: 'finalizado',
  PlanStatus.cancelado: 'cancelado',
};

const _$EnergyLevelEnumMap = {
  EnergyLevel.baja: 'baja',
  EnergyLevel.media: 'media',
  EnergyLevel.alta: 'alta',
};

const _$PlanPriceTypeEnumMap = {
  PlanPriceType.gratis: 'gratis',
  PlanPriceType.fijo: 'fijo',
  PlanPriceType.variable: 'variable',
};
