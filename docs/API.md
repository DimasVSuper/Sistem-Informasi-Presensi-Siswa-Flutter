# API Documentation

## Endpoint

- **POST** `/api/presensi`

## Request

### Headers

- `Content-Type: application/json`
- `Accept: application/json`

### Body

```json
{
  "qr_code": "<qr_code_value>"
}
```

## Response

### Success (201)

```json
{
  "message": "Presensi berhasil dicatat. Notifikasi telah dikirim ke orang tua.",
  "data": {
    "nama": "Nama Siswa",
    "nis": "123456",
    "tanggal": "2026-06-08",
    "waktu": "07:45:00",
    "status": "Hadir"
  }
}
```

### Duplicate Attendance (409)

```json
{
  "message": "Siswa <Nama> sudah melakukan presensi hari ini.",
  "data": {
    "nama": "Nama Siswa",
    "nis": "123456"
  }
}
```

### Not Found (404)

```json
{
  "message": "Siswa tidak ditemukan. QR Code tidak valid."
}
```

### Error Email Notification

Jika email orang tua tersedia tetapi gagal dikirim, pesan sukses tetap dikembalikan dan detail notifikasi disertakan dalam teks pesan:

```json
{
  "message": "Presensi berhasil dicatat. Ada yang salah dengan Sistem Email kami.",
  "data": { ... }
}
```

## Field Descriptions

- `qr_code` (string) - kode QR siswa yang dikirim dari aplikasi mobile.
- `message` (string) - pesan hasil operasi.
- `data` (object) - detail siswa dan waktu presensi.
  - `nama` (string) - nama siswa.
  - `nis` (string) - nomor induk siswa.
  - `tanggal` (string) - tanggal presensi dalam format `YYYY-MM-DD`.
  - `waktu` (string) - jam presensi dalam format `HH:mm:ss`.
  - `status` (string) - status presensi, biasanya `Hadir`.

## Notes

- Endpoint ini memeriksa apakah siswa sudah melakukan presensi pada hari yang sama.
- Jika siswa sudah hadir, server mengembalikan kode HTTP `409` dengan informasi duplikat.
- Notifikasi email dikirim ke orang tua jika alamat email tersedia.
- Seluruh operasi dijalankan di dalam transaksi database.
