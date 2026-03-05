import React, { useEffect, useState } from 'react';
import axios from 'axios';
import {
  Box, Button, Card, CardContent, Container, Divider,
  TextField, Typography, Dialog, DialogTitle,
  DialogContent, DialogActions, CircularProgress, Chip,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Alert
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import AddIcon from '@mui/icons-material/Add';
import VisibilityIcon from '@mui/icons-material/Visibility';
import RefreshIcon from '@mui/icons-material/Refresh';

function App() {
  const [devices, setDevices] = useState([]);
  const [newDevice, setNewDevice] = useState({ name: '', topic: '' });
  const [payloads, setPayloads] = useState({});
  const [telemetry, setTelemetry] = useState([]);
  const [selectedDevice, setSelectedDevice] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [telemetryLoading, setTelemetryLoading] = useState(false);
  const [telemetryError, setTelemetryError] = useState(null);

  useEffect(() => {
    fetchDevices();
  }, []);

  const fetchDevices = async () => {
    const res = await axios.get('http://localhost:8080/devices');
    setDevices(res.data);
    const initPayloads = {};
    res.data.forEach(d => initPayloads[d.id] = '');
    setPayloads(initPayloads);
  };

  const handleSend = async (id) => {
    const payload = payloads[id];
    if (!payload) return;
    await axios.post(`http://localhost:8080/devices/${id}/control`, payload, {
      headers: { 'Content-Type': 'text/plain' }
    });
    alert('Lệnh đã gửi!');
  };

  const handleCreate = async () => {
    if (!newDevice.name || !newDevice.topic) return;
    await axios.post('http://localhost:8080/devices', newDevice);
    setNewDevice({ name: '', topic: '' });
    fetchDevices();
  };

  const fetchTelemetry = async (deviceId) => {
    setTelemetryLoading(true);
    setTelemetryError(null);
    try {
      const res = await axios.get(`http://localhost:8080/telemetry/${deviceId}`);
      setTelemetry(res.data);
    } catch (err) {
      setTelemetryError('Không thể tải dữ liệu. Vui lòng thử lại.');
      setTelemetry([]);
    } finally {
      setTelemetryLoading(false);
    }
  };

  const handleViewTelemetry = async (device) => {
    setSelectedDevice(device);
    setOpenDialog(true);
    await fetchTelemetry(device.id);
  };

  const handleRefreshTelemetry = async () => {
    if (selectedDevice) await fetchTelemetry(selectedDevice.id);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setTelemetry([]);
    setTelemetryError(null);
  };

  return (
    <Container maxWidth="sm" sx={{ mt: 4 }}>
      <Typography variant="h4" textAlign="center" fontWeight="bold" gutterBottom>
        📡 IoT Device Dashboard
      </Typography>

      <Typography variant="h6" gutterBottom>📋 Danh sách thiết bị</Typography>

      {devices.map(device => (
        <Card key={device.id} sx={{ mb: 2, backgroundColor: '#f0f4ff' }}>
          <CardContent>
            <Typography fontWeight="bold">{device.name}</Typography>
            <Typography variant="body2" gutterBottom>MQTT Topic: {device.topic}</Typography>
            <TextField
              fullWidth
              label="Lệnh điều khiển"
              placeholder="{data:20}"
              multiline
              maxRows={3}
              value={payloads[device.id]}
              onChange={(e) => setPayloads({ ...payloads, [device.id]: e.target.value })}
              sx={{ mt: 1, mb: 2 }}
            />
            {/* ✅ Hai nút nằm cùng dòng, giống Flutter */}
            <Box display="flex" justifyContent="flex-end" gap={1}>
              <Button
                variant="contained"
                onClick={() => handleSend(device.id)}
                endIcon={<SendIcon />}
                sx={{ textTransform: 'none' }}
              >
                GỬI LỆNH
              </Button>
              <Button
                variant="outlined"
                onClick={() => handleViewTelemetry(device)}
                startIcon={<VisibilityIcon />}
                sx={{ textTransform: 'none' }}
              >
                XEM DỮ LIỆU
              </Button>
            </Box>
          </CardContent>
        </Card>
      ))}

      <Divider sx={{ my: 3 }} />

      <Typography variant="h6" gutterBottom>➕ Thêm thiết bị mới</Typography>
      <TextField
        fullWidth
        label="Tên thiết bị"
        variant="outlined"
        sx={{ mb: 2 }}
        value={newDevice.name}
        onChange={(e) => setNewDevice({ ...newDevice, name: e.target.value })}
      />
      <TextField
        fullWidth
        label="Topic MQTT"
        variant="outlined"
        sx={{ mb: 2 }}
        value={newDevice.topic}
        onChange={(e) => setNewDevice({ ...newDevice, topic: e.target.value })}
      />
      <Button
        variant="contained"
        fullWidth
        onClick={handleCreate}
        startIcon={<AddIcon />}
        sx={{ textTransform: 'none' }}
      >
        TẠO THIẾT BỊ
      </Button>

      {/* Dialog hiển thị telemetry */}
      {selectedDevice && (
        <Dialog open={openDialog} onClose={handleCloseDialog} fullWidth maxWidth="md">
          <DialogTitle>
            <Box display="flex" alignItems="center" justifyContent="space-between">
              <Box display="flex" alignItems="center" gap={1}>
                <VisibilityIcon fontSize="small" />
                <span>Telemetry — {selectedDevice.name}</span>
                {!telemetryLoading && !telemetryError && (
                  <Chip
                    label={`${telemetry.length} bản ghi`}
                    size="small"
                    color={telemetry.length > 0 ? 'primary' : 'default'}
                  />
                )}
              </Box>
              <Button
                size="small"
                startIcon={<RefreshIcon />}
                onClick={handleRefreshTelemetry}
                disabled={telemetryLoading}
              >
                Refresh
              </Button>
            </Box>
          </DialogTitle>

          <DialogContent dividers sx={{ minHeight: 200 }}>
            {telemetryLoading ? (
              <Box display="flex" justifyContent="center" alignItems="center" minHeight={150}>
                <CircularProgress />
              </Box>
            ) : telemetryError ? (
              <Alert severity="error">{telemetryError}</Alert>
            ) : telemetry.length === 0 ? (
              <Alert severity="info">Chưa có dữ liệu telemetry cho thiết bị này.</Alert>
            ) : (
              <TableContainer component={Paper} variant="outlined">
                <Table size="small">
                  <TableHead>
                    <TableRow sx={{ backgroundColor: '#f0f4ff' }}>
                      <TableCell><b>#</b></TableCell>
                      <TableCell><b>Giá trị (Value)</b></TableCell>
                      <TableCell><b>Thời gian (Timestamp)</b></TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {telemetry.map((t, i) => (
                      <TableRow key={i} hover>
                        <TableCell>{i + 1}</TableCell>
                        <TableCell>
                          <Typography variant="body2" fontFamily="monospace">
                            {t.payload}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Typography variant="caption" color="text.secondary">
                            {new Date(t.timestamp).toLocaleString('vi-VN')}
                          </Typography>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            )}
          </DialogContent>

          <DialogActions>
            <Button onClick={handleCloseDialog} color="inherit">Đóng</Button>
          </DialogActions>
        </Dialog>
      )}
    </Container>
  );
}

export default App;
