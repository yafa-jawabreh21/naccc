import React, { useState } from 'react'

const API = import.meta.env.VITE_API_BASE || 'http://localhost:8000'

export default function App() {
  const [health, setHealth] = useState<any>(null)
  const [evm, setEvm] = useState<any>(null)

  const ping = async () => {
    const r = await fetch(`${API}/health`)
    setHealth(await r.json())
  }

  const calcEvm = async () => {
    const r = await fetch(`${API}/evm/compute`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ pv: 100, ev: 90, ac: 110 })
    })
    setEvm(await r.json())
  }

  return (
    <div className="min-h-screen p-6">
      <div className="max-w-3xl mx-auto space-y-6">
        <h1 className="text-3xl font-bold">Tabanah Galaxy</h1>
        <div className="space-x-3">
          <button className="px-4 py-2 rounded bg-gray-200" onClick={ping}>Health</button>
          <button className="px-4 py-2 rounded bg-gray-200" onClick={calcEvm}>EVM Demo</button>
        </div>
        {health && <pre className="p-3 bg-gray-100 rounded">{JSON.stringify(health, null, 2)}</pre>}
        {evm && <pre className="p-3 bg-gray-100 rounded">{JSON.stringify(evm, null, 2)}</pre>}
      </div>
    </div>
  )
}
