import { useState, useEffect } from "react";

import Select from "react-select";
import AsyncSelect from "react-select/async";

import DatePicker from "react-date-picker";
import { format } from "date-fns";

import {
  ResponsiveContainer,
  BarChart,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Bar,
} from "recharts";

import CountUp from "react-countup";

import "react-date-picker/dist/DatePicker.css";
import "react-calendar/dist/Calendar.css";

import sketchyLogo from "./sketchy_logo.svg";
import "./App.css";

const yearOptions = [
  { label: "POST_GRAD", value: "POST_GRAD" },
  { label: "SECOND_YEAR", value: "SECOND_YEAR" },
  { label: "OTHER", value: "OTHER" },
  { label: "THIRD_YEAR", value: "THIRD_YEAR" },
  { label: "FOURTH_YEAR", value: "FOURTH_YEAR" },
  { label: "RESEARCH_YEAR", value: "RESEARCH_YEAR" },
  { label: "FIRST_YEAR", value: "FIRST_YEAR" },
];

function App() {
  const [startDate, setStartDate] = useState("2020-01-01");
  const [endDate, setEndDate] = useState(format(new Date(), "yyyy-MM-dd"));
  const [univName, setUnivName] = useState(null);
  const [univId, setUnivId] = useState(null);
  const [programYear, setProgramYear] = useState(null);

  const [total, setTotal] = useState(0);
  const [timeseries, setTimeseries] = useState([]);

  const getUniversities = async (q) => {
    try {
      const res = await fetch(`http://localhost:5000/api/universities?q=${q}`);
      const d = await res.json();
      return d;
    } catch (err) {
      console.error(err);
      return [];
    }
  };

  useEffect(() => {
    let url = `http://localhost:5000/api/subs-over-time?start=${startDate}&end=${endDate}`;
    let url2 = `http://localhost:5000/api/total-subs?start=${startDate}&end=${endDate}`;
    if (univId !== null) {
      url = url + `&university_id=${univId}`;
      url2 = url2 + `&university_id=${univId}`;
    }
    if (programYear) {
      url = url + `&program_year=${programYear}`;
      url2 = url2 + `&program_year=${programYear}`;
    }
    fetch(url)
      .then((res) => res.json())
      .then((d) => setTimeseries(d));

    fetch(url2)
      .then((res) => res.json())
      .then((d) => setTotal(d.total));
  }, [startDate, endDate, univId, programYear]);

  const handleUniv = (e) => {
    if (e) {
      setUnivId(e.value);
      setUnivName(e.label);
    } else {
      setUnivId(null);
      setUnivName(null);
    }
  };

  return (
    <div className="App">
      <div className="App-header">
        <img className="sketchy-logo" src={sketchyLogo} alt="" />
      </div>
      <div className="body">
        <DatePicker
          value={startDate}
          onChange={(e) => setStartDate(format(e, "yyyy-MM-dd"))}
          format="y-MM-dd"
          clearIcon={null}
        />
        <DatePicker
          value={endDate}
          onChange={(e) => setEndDate(format(e, "yyyy-MM-dd"))}
          format="y-MM-dd"
          clearIcon={null}
        />
        <div className="dropdowns">
          <Select
            isClearable={true}
            options={yearOptions}
            onChange={(e) => {
              if (e) setProgramYear(e.value);
              else setProgramYear(null);
            }}
            placeholder="Program Year..."
          />
          <AsyncSelect
            cacheOptions
            isClearable={true}
            loadOptions={getUniversities}
            onChange={handleUniv}
            styles={{
              control: (baseStyles) => ({
                ...baseStyles,
                width: 500,
              }),
            }}
            placeholder="University..."
          />
        </div>

        <div className="date-display">
          <span className="date-display-span">{startDate}</span> TO
          <span className="date-display-span">{endDate}</span>
          {univName ? `(${univName})` : ""}
        </div>

        <div className="total-subs">
          {total > 0 ? (
            <h1>
              <CountUp end={total} duration={1} /> Total Subs
            </h1>
          ) : null}
        </div>

        {/* <pre>{JSON.stringify(timeseries, null, 2)}</pre> */}
        <h1>Total Active Subscriptions (by month)</h1>
        <ResponsiveContainer height={750} width="100%">
          <BarChart data={timeseries}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="total" fill="#008ec4" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

export default App;
