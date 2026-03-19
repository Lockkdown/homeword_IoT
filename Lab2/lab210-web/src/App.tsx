import { useEffect, useRef, useState } from 'react'
import mqtt from 'mqtt'
import type { MqttClient } from 'mqtt'
import './App.css'

const BROKER_URL = 'ws://10.98.121.184:8083/mqtt'
const LED_TOPIC = '/topic/led/control'

function App() {
  const [ledOn, setLedOn] = useState(false)
  const [connected, setConnected] = useState(false)
  const clientRef = useRef<MqttClient | null>(null)

  useEffect(() => {
    const client = mqtt.connect(BROKER_URL, {
      clientId: 'web_' + Math.random().toString(16).slice(2),
      clean: true,
      reconnectPeriod: 3000,
    })

    client.on('connect', () => {
      setConnected(true)
      client.subscribe(LED_TOPIC, { qos: 1 })
    })

    client.on('disconnect', () => setConnected(false))
    client.on('error', () => setConnected(false))

    client.on('message', (_topic, payload) => {
      const msg = payload.toString()
      if (msg === '1') setLedOn(true)
      else if (msg === '0') setLedOn(false)
    })

    clientRef.current = client
    return () => { client.end() }
  }, [])

  const toggle = () => {
    if (!clientRef.current || !connected) return
    const next = !ledOn
    clientRef.current.publish(LED_TOPIC, next ? '1' : '0', { qos: 1, retain: true })
  }

  return (
    <div className="container">
      <h1 className="title">IoT LED Control</h1>

      <div className={`status-badge ${connected ? 'online' : 'offline'}`}>
        <span className="status-dot" />
        {connected ? 'Broker connected' : 'Connecting...'}
      </div>

      <div className="card">
        <div className="led-indicator" style={{ background: ledOn ? '#facc15' : '#334155' }}>
          <div className={`led-glow ${ledOn ? 'active' : ''}`} />
        </div>

        <p className="led-label">{ledOn ? 'ON' : 'OFF'}</p>

        <button
          className={`toggle-btn ${ledOn ? 'btn-on' : 'btn-off'}`}
          onClick={toggle}
          disabled={!connected}
        >
          {ledOn ? 'Turn OFF' : 'Turn ON'}
        </button>
      </div>

      <p className="hint">Topic: <code>{LED_TOPIC}</code></p>
    </div>
  )
}

export default App
