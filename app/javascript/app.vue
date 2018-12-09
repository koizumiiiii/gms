<template>
  <div id="app">
    <h1 class="title"></h1>
      <div v-show="formTask.show" class="form_task_wrapper">
        <div class="form_task_inner">
          <div v-if="!formTask.id" class="form_task_inner__btn_area">
            <button class="btn_cancel" v-on:click="cancelNewTask" type="button">閉じる</button>
            <span>新しいタスク</span>
            <button class="btn_add" v-on:click="addNewTask" type="button">追加する</button>
          </div>
          <div v-if="formTask.id" class="form_task_inner__btn_area">
            <button class="btn_cancel" v-on:click="cancelNewTask" type="button">閉じる</button>
            <span>タスクの更新</span>
            <button class="btn_update" v-on:click="updateTask" type="button">更新する</button>
          </div>
          <div class="form_task_inner__input_area">
            <input v-model="formTask.title" type="text" name="title" placeholder="タスクタイトル" />
            <input v-model="formTask.startAt" type="datetime-local" name="start_at"/>
            <vue-google-autocomplete
              ref="formTask.place"
              id="map"
              name="place"
              classname="form-control"
              placeholder="場所"
              types=""
              country="jp"
              v-on:placechanged="getAddressData"
              v-model="formTask.place"
            >
            </vue-google-autocomplete>
            <input v-model="formTask.lat" type="hidden" name="lat" />
            <input v-model="formTask.lon" type="hidden" name="lon" />
            <input v-model="formTask.weather" type="hidden" name="weather" />
            <textarea v-model="formTask.detail" placeholder="メモ" class="" rows="4" cols="40" /></textarea>
            <div v-if="formTask.id" class="form_task_inner__input_area__delete">
              <button class="btn_delete" type="button" v-on:click="deleteTask">タスクの削除</button>
            </div>
          </div>
        </div>
      </div>
    <div v-show="!formTask.show" class="form_task_btn">
      <button id="new_task" v-on:click="showNewTask">+</button>
    </div>
    <section v-cloak v-for="(monthList, monthIndex) in taskList" v-bind:id="monthList.month" class="task_wrapper">
      <h2 class="task_ym">{{monthList.month}}</h2>
      <ul>
        <li v-on:click="changeTask" v-for="(task, taskIndex) in monthList.tasks" v-bind:id="'row_task_' + task.id" v-bind:data-month-index="monthIndex" v-bind:data-task-index="taskIndex" class="task_list">
          <div class="task_head">
              <time class="task_day">{{task.start_at.slice(8, 10)}}</time>
              <p class="task_head__week" v-html="dayOfWeek(task.start_at)"></p>
          </div>
          <div class="task_body">
            <time class="task_time">{{task.start_at.slice(11, 16)}}</time>
            <p class="task_body__txt">{{task.title}}</p>
          </div>
          <div v-if="task.weather_infomation" class="icon_weather">
            <img v-bind:src="task.weather_infomation">
            <span class="temp">{{task.temperature}}</span>
          </div>
          <div v-else class="icon_weather">－</div>
        </li>
      </ul>
    </section>
    <div id="loading" class="icon_loading" v-observe-visibility="visibilityChanged"><img v-show="isVisibleLoadicon" src="/images/icon_loader.gif"></div>
  </div>
</template>

<script>
import VueGoogleAutocomplete from 'vue-google-autocomplete'
import axios from 'axios';

const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token

export default {
  components: { VueGoogleAutocomplete },
  data: function () {
    return {
      formTask: {
        id : null,
        show: false,
        startAt: '',
        title: '',
        place: '',
        lat: '',
        lon: '',
        weather: '',
        temperature: '',
        detail: ''
      },
      isVisibleLoadicon: true,
      taskList: [],
      isActive: false
    }
  },
  mounted: function() {
    this.fetchTasks();
  },
  methods: {
    visibilityChanged: function(isVisibleLoadicon) {
      if (isVisibleLoadicon && this.$data.taskList.length > 0) {
        // 次のn件をロードする
        var monthArray = this.$data.taskList;
        var lastMonth = monthArray[monthArray.length - 1];
        var taskArray = lastMonth.tasks;
        var lastTask = taskArray[taskArray.length - 1];
        console.log(lastTask.visibility_state);
        axios.get('/tasks/task_list', {
          params: {
          // this.$data.taskListの一番最後のtaskのstarAtとidを指定する
            next_start_at: lastTask.start_at,
            next_id: lastTask.id
          }
        }).then((response) => {
          if (Object.keys(response.data).length > 0) {
            this.buildTaskList(response.data);
          } else {
            this.$data.isVisibleLoadicon = false
          }
        })
      }
    },
    getAddressData: function (addressData, placeResultData, id) {
      this.$data.formTask.place = placeResultData.name;
      this.$data.formTask.lat = addressData.latitude;
      this.$data.formTask.lon = addressData.longitude;
    },
    resetFormData: function () {
      this.$data.formTask.id = '';
      this.$data.formTask.title = '';
      this.$data.formTask.place = '';
      this.$data.formTask.detail = '';
      this.$data.formTask.startAt = '';
    },
    addNewTask: function() {
      // api succese or error
      axios.post('/tasks/add_task', {
        task: {
          title: this.$data.formTask.title,
          place: this.$data.formTask.place,
          latitude: this.$data.formTask.lat,
          longitude: this.$data.formTask.lon,
          weather_infomation: this.$data.formTask.weather,
          temperature: this.$data.formTask.temperature,
          detail: this.$data.formTask.detail,
          start_at: this.$data.formTask.startAt
        }
      }).then((response) => {
        if (response.data.success) {
          this.resetFormData();
          this.$data.formTask.show = false;
          this.fetchTasks();
        } else {
          alert("error!");
        }
      });
    },
    updateTask: function() {
      // api succese or error
      axios.post('/tasks/' + this.$data.formTask.id + '/update_task', {
        task: {
          title: this.$data.formTask.title,
          place: this.$data.formTask.place,
          latitude: this.$data.formTask.lat,
          longitude: this.$data.formTask.lon,
          weather_infomation: this.$data.formTask.weather,
          temperature: this.$data.formTask.temperature,
          detail: this.$data.formTask.detail,
          start_at: this.$data.formTask.startAt
        }
      }).then((response) => {
        if (response.data.success) {
          this.resetFormData();
          this.$data.formTask.show = false;
          this.fetchTasks();
        } else {
          alert("error!");
        }
      });
    },
    editTaskDisplayed: function() {
      /*
      if (navigator.userAgent.match(/(iPad|iPhone|iPod)/g)) {
        setTimeout(function() {
          console.log("hoge");
          var container = document.getElementsByClassName('pac-container');
          console.log(container);
          if (container && container.length > 0) {
            console.log("uga");
            container[0].addEventListener('touchend', function(e) {
              e.stopImmediatePropagation();
            });
          }
        }, 500);
      }
      */
    },
    cancelNewTask: function() {
      this.$data.formTask.show = false;
      this.resetFormData();
    },
    showNewTask: function(event) {
      this.$data.formTask.show = true;
      this.editTaskDisplayed();
    },
    changeTask: function(event) {
      var monthIndex = parseInt(event.currentTarget.getAttribute('data-month-index'));
      var taskIndex = parseInt(event.currentTarget.getAttribute('data-task-index'));

      var targetTask = this.$data.taskList[monthIndex].tasks[taskIndex];
      this.$data.formTask.id = targetTask.id;
      this.$data.formTask.title = targetTask.title;
      this.$data.formTask.place = targetTask.place;
      this.$data.formTask.detail = targetTask.detail;
      this.$data.formTask.startAt = targetTask.start_at.slice(0, 16);
      this.$data.formTask.lat = targetTask.latitude;
      this.$data.formTask.lon = targetTask.longitude;
      this.$data.formTask.weather = targetTask.weather_information;
      this.$data.formTask.temperature = targetTask.temperature;
      this.$data.formTask.show = true;
      this.editTaskDisplayed();

      // vue-google-autocompleteの処理でv-modelのバインドが動かないので、強引に値を上書きしている。
      setTimeout(function(){
        document.getElementById('map').value = targetTask.place;
      });
    },

    buildTaskList: function(taskArray) {
      for (var i in taskArray) {
        var task = taskArray[i];

        // weather_iconと気温
        if (task.weather_infomation) {
          var weatherArray = JSON.parse(task.weather_infomation);
          var keysWeather = Object.keys(weatherArray.list);
          var lenKeysWeather = keysWeather.length;
          var startingDateWeather = weatherArray.list[keysWeather[lenKeysWeather - 1]];
          task.weather_infomation = `//openweathermap.org/img/w/${startingDateWeather.weather[0]['icon']}.png`;
          task.temperature = Math.ceil(startingDateWeather.main.temp * 10 ) / 10 + '℃';
        }

        var month = task.start_at.slice(0, 7).replace('-', '/');
        var monthData = this.$data.taskList.find(function(element) {
          return element.month == month;
        });
      	if (typeof(monthData) == 'undefined') {
          monthData = { month: month, tasks: [] }
          this.$data.taskList.push(monthData);
      	}

        var foundIndex = monthData.tasks.findIndex(function(element) {
          return element.start_at > task.start_at;
        });
        if (foundIndex >= 0) {
          monthData.tasks.splice(foundIndex, 0, task);
        } else {
          monthData.tasks.push(task);
        }
      }
    },
    dayOfWeek: function(start_at) {
      var WeekChars = [ "日", "月", "火", "水", "木", "金", "土" ];
      var dObj = new Date(start_at);
      var wDay = dObj.getDay();
      var sunColor = `<span style="color: #ff5561;">${WeekChars[wDay]}</span>`;
      var satColor = `<span style="color: #55a1ff;">${WeekChars[wDay]}</span>`;
      if (wDay == 0) {
        return sunColor;
      } else if (wDay == 6) {
        return satColor;
      } else {
        return WeekChars[wDay];
      }
    },
    deleteTask: function() {
      if(window.confirm('削除してもいいですか？')){
        axios.post('/tasks/' + this.$data.formTask.id + '/delete_task', {
          task: {
            title: this.$data.formTask.title,
            place: this.$data.formTask.place,
            latitude: this.$data.formTask.lat,
            longitude: this.$data.formTask.lon,
            weather_infomation: this.$data.formTask.weather,
            temperature: this.$data.formTask.temperature,
            detail: this.$data.formTask.detail,
            start_at: this.$data.formTask.startAt
          }
        }).then((response) => {
          if (response.data.success) {
            this.resetFormData();
            this.$data.formTask.show = false;
            this.fetchTasks();
          } else {
            alert("error!");
          }
        });
      }
    },
    fetchTasks: function() {
      this.$data.taskList = [];
      axios.get('/tasks/task_list').then((response) => {
        this.buildTaskList(response.data);
      })
    }
  }
}

</script>

<style>
</style>
